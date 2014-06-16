//
//  FOSSendServerRecordOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/10/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSSendServerRecordOperation.h"
#import "FOSSendToOneRelationshipOperation.h"
#import "FOSSendToManyRelationshipOperation.h"
#import "FOSLoginManager_Internal.h"

@implementation FOSSendServerRecordOperation {
    NSManagedObjectID *_cmoID;
    BOOL _isLoginUserRecord;
    __block FOSURLBinding *_urlBinding;
    __block FOSWebServiceRequest *_webServiceRequest;
    __block NSError *_error;
}

#pragma mark - Property Overrides

- (FOSCachedManagedObject *)cmo {
    NSManagedObjectContext *moc = _isLoginUserRecord
        ? [FOSLoginManager loginUserContext]
        : self.managedObjectContext;

    FOSCachedManagedObject *result = (FOSCachedManagedObject *)[moc objectWithID:_cmoID];

    NSAssert(result != nil, @"No cmo???");
    NSAssert([result isKindOfClass:[FOSCachedManagedObject class]], @"Wrong class??");

    return result;
}

- (NSError *)error {
    NSError *result = _error;

    if (result == nil) {
        result = [super error];
    }

    return result;
}

- (void)main {
    [super main];

    if (!self.isCancelled && (self.error == nil)) {
        self.cmo.updatedWithServerAt = [NSDate date];
        [self.cmo markClean];
    }
}

#pragma mark - Initialization Methods

- (id)initWithCMO:(FOSCachedManagedObject *)cmo
forLifecyclePhase:(FOSLifecyclePhase)lifecyclePhase
withLifecycleStyle:(NSString *)lifecycleStyle{

    NSParameterAssert(cmo != nil);
    NSParameterAssert(lifecyclePhase == FOSLifecyclePhaseCreateServerRecord ||
                      lifecyclePhase == FOSLifecyclePhaseUpdateServerRecord);

    if ((self = [super init]) != nil) {

        NSError *error = nil;
        if ([self.managedObjectContext obtainPermanentIDsForObjects:@[ cmo ] error:&error]) {
            _cmoID = cmo.objectID;
            _lifecyclePhase = lifecyclePhase;
            _lifecycleStyle = lifecycleStyle;

            if ((lifecyclePhase == FOSLifecyclePhaseCreateServerRecord ||
                lifecyclePhase == FOSLifecyclePhaseLogin) &&
                [cmo isKindOfClass:[FOSUser class]]) {
                _isLoginUserRecord = ((FOSUser *)cmo).isLoginUser;
            }

            // Delay creation of webServiceRequest to BG thread.  We want to do this as there
            // might be a fair amount of overhead in creating the entire hierarchy and we don't want
            // to block the main thread.  This will also allow saved values to stabilize into the
            // bg contexts.
            __block FOSSendServerRecordOperation *blockSelf = self;

            FOSBackgroundOperation *bgOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

                if (!cancelled && (error == nil)) {

                    // Send our to-One records 1st as we need their ids to push this records
                    FOSOperation *sendToOneRelsOp = [blockSelf _sendDependentServerRecords:YES];

                    // Next send our record
                    FOSOperation *sendCMOOp = [blockSelf _sendCMO];
                    [sendCMOOp addDependency:sendToOneRelsOp];

                    [blockSelf addDependency:sendCMOOp];
                    [blockSelf.restConfig.cacheManager reQueueOperation:blockSelf];
                }
            }];

            [self addDependency:bgOp];
        }
        else {
            _error = error;
        }
    }

    return self;
}

#pragma mark - Private Methods

- (FOSOperation *)_sendCMO {
    __block FOSSendServerRecordOperation *blockSelf = self;

    FOSOperation *result = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        if (!cancelled && (error == nil)) {
            NSError *localError = nil;
            FOSCachedManagedObject *cmo = blockSelf.cmo;
            FOSRESTConfig *restConfig = blockSelf.restConfig;
            FOSURLBinding *urlBinding =
                [restConfig.restServiceAdapter urlBindingForLifecyclePhase:blockSelf.lifecyclePhase
                                                         forLifecycleStyle:blockSelf.lifecycleStyle
                                                           forRelationship:nil
                                                                 forEntity:cmo.entity];
            FOSWebServiceRequest *webServiceRequest = nil;

            // Create a request to send our changes
            if ((blockSelf.lifecyclePhase == FOSLifecyclePhaseCreateServerRecord) ||
                cmo.hasModifiedProperties) {

                if (urlBinding != nil) {
                    NSURLRequest *urlRequest = [urlBinding urlRequestForCMO:cmo error:&localError];

                    if (localError == nil) {
                        webServiceRequest = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                          forURLBinding:urlBinding];
                    }
                }
                else {
                    NSString *msgFmt = @"Missing URL_BINDING for lifecycle %@ lifecycle style '%@' for Entity '%@'";
                    NSString *msg = [NSString stringWithFormat:msgFmt,
                                     [FOSURLBinding stringForLifecycle:blockSelf.lifecyclePhase],
                                     blockSelf.lifecycleStyle,
                                     cmo.entity.name];

                    localError = [NSError errorWithMessage:msg];
                }
            }

            if (localError == nil) {
                blockSelf->_urlBinding = urlBinding;
                blockSelf->_webServiceRequest = webServiceRequest;

                // Chain in the next operation
                FOSOperation *updateCMO = [blockSelf _updateCMO];

                if (webServiceRequest != nil) {
                    [updateCMO addDependency:webServiceRequest];
                }

                [blockSelf addDependency:updateCMO];

                [blockSelf.restConfig.cacheManager reQueueOperation:blockSelf];
            }
            else {
                blockSelf->_error = localError;
            }
        }
    }];

    return result;
}

- (FOSOperation *)_updateCMO {
    __block FOSSendServerRecordOperation *blockSelf = self;

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {

        if (!cancelled && (error == nil)) {
            NSError *localError = nil;

            // Now that we've got info from the web service, allow subtypes
            // to store info, if necessary.
            if (blockSelf->_webServiceRequest != nil) {
                NSDictionary *json = (NSDictionary *)blockSelf->_webServiceRequest.jsonResult;
                [blockSelf->_urlBinding.cmoBinding updateCMO:blockSelf.cmo
                                                    fromJSON:json
                                           forLifecyclePhase:blockSelf->_lifecyclePhase
                                                       error:&localError];

                if (localError == nil) {
                    [blockSelf.cmo markClean];

                    // Except for FOSUser, those get dumped before saving and are
                    // only saved when pulled through GET.
                    if (![blockSelf.cmo isKindOfClass:[FOSUser class]]) {

                        // Send only records don't have any ids, so once their pushed
                        // to the server, delete them.
                        if (blockSelf.cmo.isSendOnly) {
                            blockSelf.cmo.skipServerDelete = YES;

                            NSManagedObjectContext *moc = blockSelf.managedObjectContext;
                            [moc deleteObject:blockSelf.cmo];
                        }

                        // Push those changes to the DB now!  This is so that we don't
                        // lose any objectIds that come back from the server.
                        [blockSelf.restConfig.databaseManager saveChanges];
                    }
                }
            }

            if (localError == nil) {
                // Chain in the next step
                FOSOperation *sendToManyRelsOp = [blockSelf _sendDependentServerRecords:NO];

                [blockSelf addDependency:sendToManyRelsOp];

                [blockSelf.restConfig.cacheManager reQueueOperation:blockSelf];
            }
            else {
                blockSelf->_error = localError;
            }
        }
    }];
    
    return finalOp;
}

- (FOSOperation *)_sendDependentServerRecords:(BOOL)sendToOneRecords {
    __block FOSSendServerRecordOperation *blockSelf = self;

    FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL cancelled, NSError *error) {
        // Nothing to do, this is just a leaf
    }];

    // Traverse our owned relationships and send them to the server as well
    for (NSRelationshipDescription *relDesc in self.cmo.entity.cmoOwnedRelationships) {
        FOSOperation *relOp = nil;

        NSMutableSet *parentIDs = self.parentSentIDs == nil
            ? [NSMutableSet set]
            : [self.parentSentIDs mutableCopy];

        NSAssert(![parentIDs containsObject:self.cmo.objectID], @"Shouldn't have made it in !");
        [parentIDs addObject:self.cmo.objectID];

        // To-one relationship
        if (!relDesc.isToMany && sendToOneRecords) {
            relOp = [FOSSendToOneRelationshipOperation operationForCMO:blockSelf.cmo
                                                       forRelationship:relDesc
                                                         parentSentIDs:parentIDs];
        }
        else if (relDesc.isToMany && !sendToOneRecords) {
            relOp = [FOSSendToManyRelationshipOperation operationForCMO:blockSelf.cmo
                                                        forRelationship:relDesc
                                                          parentSentIDs:parentIDs];
        }

        if (relOp != nil) {
            // Wait until the dep op has completed, if we had any changes
            if (blockSelf->_webServiceRequest != nil) {
                [relOp addDependency:blockSelf->_webServiceRequest];
            }

            [finalOp addDependency:relOp];
        }
    }

    return finalOp;
}

@end
