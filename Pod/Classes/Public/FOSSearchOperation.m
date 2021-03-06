//
//  FOSSearchOperation.m
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <FOSSearchOperation.h>
#import "FOSREST_Internal.h"

@implementation FOSSearchOperation {
    FOSCacheSearchHandler _searchHandler;
    BOOL _pullObjectsToForeground;
}

#pragma mark - Public methods

- (void)performSearch {
    [self performSearchAndInform:nil];
}

- (void)performSearchAndInform:(FOSCacheSearchHandler)searchHandler {
    NSAssert([NSThread isMainThread], @"Searches can only be performed from the main thread.");

    _searchHandler = [searchHandler copy];
    _pullObjectsToForeground = YES;

    NSError *localError = nil;
    __block FOSSearchOperation *blockSelf = self;

    if (self.restConfig.networkStatus != FOSNetworkStatusNotReachable) {
        NSSet *depOps = [self dependentSearchOperations:&localError];

        if (localError == nil) {
            // This operation will 'cover' any errors found if they were to be ignored, which
            // allows the final operation to save the changes to the database.
            FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRecoverableRequest:^FOSRecoveryOption(BOOL cancelled, NSError *error) {
                FOSRecoveryOption result = blockSelf->_saveIndividualResults
                    ? FOSRecoveryOption_Recovered
                    : FOSRecoveryOption_NoRecovery;

                return result;
            }];

            // This op is dependent on all other search ops
            for (FOSOperation *nextDepOp in depOps) {
                [finalOp addDependency:nextDepOp];
            }

            // Queue the ops
            NSString *groupName = [NSString stringWithFormat:@"Performing %@ search",
                                   NSStringFromClass([self class])];
            [self.restConfig.cacheManager queueOperation:finalOp
                                 withCompletionOperation:self
                                           withGroupName:groupName];
        }
        else if (_searchHandler != nil) {
            searchHandler(nil, localError);
        }
    }
    else if (_searchHandler != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            blockSelf->_searchHandler(nil, nil);
        });
    }
}

#pragma mark - Overrides

- (NSError *)error {
    NSError *result = nil;

    if (!_saveIndividualResults) {
        result = [super error];
    }

    return result;
}

- (void)main {
    [super main];

    NSAssert(_searchHandler == nil || _pullObjectsToForeground,
             @"Search handlers can only be called if this is a Main Thread search.");

    if (_pullObjectsToForeground) {
        __block FOSSearchOperation *blockSelf = self;
        
        if (!self.isCancelled && self.error == nil) {

            // Setup to inform the handler when we're done

            // Now that we've gotten all of the info, and updates have been saved
            // to the db, process the results and send them to the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                NSSet *bgResults = self.results;
                NSMutableSet *fgResults = [NSMutableSet setWithCapacity:bgResults.count];

                if (!self.isCancelled) {
                    NSManagedObjectContext *fgCtxt = self.managedObjectContext;

                    for (NSManagedObjectID *bgObjID in bgResults) {
                        NSError *error = nil;
                        NSManagedObject *fbObj = [fgCtxt existingObjectWithID:bgObjID
                                                                        error:&error];

                        if (error == nil) {

                            // It's possible that the object that was found is not yet
                            // in the other thread's queue.
                            if (fbObj != nil) {
                                [fgResults addObject:fbObj];
                            }
                        }

                        // If we were saving individual results, we might have deleted the
                        // object if it was invalid.
                        else if (!self.saveIndividualResults) {
                            NSString *msg = [NSString stringWithFormat:@"Failed to bring background object to foreground thread: %@",
                                             error.description];

                            @throw [NSException exceptionWithName:@"FOSCacheManagerForegroundSync"
                                                           reason:msg
                                                         userInfo:nil];
                        }
                    }
                }
                
                if (blockSelf->_searchHandler != nil) {
                    blockSelf->_searchHandler(fgResults, nil);
                }
            });
        }
        else {
            if (_searchHandler != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    blockSelf->_searchHandler(nil, self.error);
                });
            }
        }
    }
}

#pragma mark - Private Methods

- (void)finalizeDependencies {
    NSError *localError = nil;
    NSSet *depOps = [self dependentSearchOperations:&localError];

    // TODO : Something doesn't seem quite right as nothing is calling this method.
    NSAssert(localError == nil, @"Error: %@", localError.description);

    // This op is dependent on all other search ops
    for (FOSOperation *nextDepOp in depOps) {
        [self addDependency:nextDepOp];
    }
}

- (NSSet *)dependentSearchOperations:(NSError **)error {
    NSParameterAssert(error != nil);

    *error = nil;
    NSMutableSet *result = [NSMutableSet setWithCapacity:2];
    NSEntityDescription *entity = [self.managedClass entityDescription];
    NSError *localError = nil;

    FOSURLBinding *urlBinding =
        [self.restAdapter urlBindingForLifecyclePhase:FOSLifecyclePhaseRetrieveServerRecords
                                    forLifecycleStyle:nil
                                      forRelationship:nil
                                            forEntity:entity];

    if (urlBinding == nil) {
        NSString *msgFmt = @"Missing required URL_BINDING for %@ phase for entity %@.";
        NSString *msg = [NSString stringWithFormat:msgFmt,
                         [FOSURLBinding stringForLifecycle:FOSLifecyclePhaseRetrieveServerRecords],
                         entity.name];

        localError = [NSError errorWithDomain:@"FOSREST" andMessage:msg];
    }

    if (localError == nil) {
        NSURLRequest *urlRequest = [urlBinding urlRequestServerRecordOfType:entity
                                                               withDSLQuery:self.dslQuery
                                                                      error:&localError];
        if (localError == nil) {
            FOSWebServiceRequest *request = [FOSWebServiceRequest requestWithURLRequest:urlRequest
                                                                          forURLBinding:urlBinding];

            FOSOperation *procOp = [self processSearchResults:request];

            [result addObject:procOp];
        }
    }

    if (localError != nil) {
        *error = localError;
        result = nil;
    }

    return result;
}

- (FOSOperation *)processSearchResults:(FOSWebServiceRequest *)webRequest {
    NSParameterAssert(webRequest != nil);

    __block FOSSearchOperation *blockSelf = self;

    __block NSMutableSet *newEntities = [NSMutableSet set];

    // The top-level operation that will handle the pulled results
    __block FOSBackgroundOperation *finalOp =  [FOSBackgroundOperation backgroundOperationWithRecoverableRequest:^FOSRecoveryOption(BOOL cancelled, NSError *error) {
        FOSRecoveryOption result = blockSelf->_saveIndividualResults
        ? FOSRecoveryOption_Recovered
        : FOSRecoveryOption_NoRecovery;

        blockSelf.results = newEntities;

        return result;
    }];

    // An operation to process the results of the given webRequest
    FOSBackgroundOperation *webProcOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {

        if (!isCancelled && error == nil && !blockSelf.isCancelled) {
            NSError *localError = nil;
            NSArray *jsonFragments = nil;

            if ([webRequest.jsonResult isKindOfClass:[NSArray class]]) {
                jsonFragments = (NSArray *)webRequest.jsonResult;
            }
            else {
                NSString *msgFormat = @"Expected search response as an NSArray, but received %@ for request: %@.  Is it possible that a JSON_WRAPPER_KEY specification is missing?";
                NSString *msg = [NSString stringWithFormat:msgFormat,
                                 NSStringFromClass([webRequest.jsonResult class]),
                                 webRequest.url];

                localError = [NSError errorWithMessage:msg];
                blockSelf->_error = localError;
            }

            NSMutableArray *newTopLevelOps = [NSMutableArray arrayWithCapacity:jsonFragments.count];
            NSEntityDescription *entity = [blockSelf.managedClass entityDescription];
            NSMutableArray *fetchIds = [NSMutableArray arrayWithCapacity:jsonFragments.count];

            if (localError == nil) {
                Class entityClass = self.managedClass;

                FOSURLBinding *urlBinding = webRequest.urlBinding;
                FOSCMOBinding *recordBinding = urlBinding.cmoBinding;

                for (NSDictionary *jsonFragment in jsonFragments) {
                    FOSJsonId jsonId = [recordBinding jsonIdFromJSON:jsonFragment
                                                           forEntity:entity
                                                               error:&localError];

                    if (localError == nil) {
                        if (jsonId != nil) {
                            // Make sure this object hasn't been deleted locally. No reason to fetch items
                            // from the server that are queued to be deleted.
                            BOOL itemDeleted = [FOSDeletedObject existsDeletedObjectWithId:jsonId
                                                                                   andType:entityClass];

                            if (!itemDeleted) {
                                [fetchIds addObject:jsonId];
                            }
                        }
                        else {
                            NSString *msgFmt = @"The CMO_BINDING returned a nil for the ID_ATTRIBUTE binding when binding against the json fragment: %@";
                            NSString *msg = [NSString stringWithFormat:msgFmt, jsonFragment.description];

                            blockSelf->_error = [NSError errorWithMessage:msg
                                                                  forAtom:recordBinding.identityBinding];
                        }
                    }
                    else {
                        blockSelf->_error = localError;
                    }
                }
            }

            if (blockSelf->_error == nil) {
                NSMutableDictionary *bindings = [FOSRetrieveCMOOperation primeBindingsForEntity:entity
                                                                                    withJsonIDs:fetchIds];

                // Process the fragments of the web request adding further dependencies
                // to the 'finalOp' to complete the processing of each request.
                for (NSDictionary *nextPlaceDict in jsonFragments) {

                    // Get a fetch request for this json
                    FOSRetrieveCMOOperation *fetchEntityOp =
                    [FOSRetrieveCMOOperation retrieveCMOForEntity:entity
                                                         withJson:nextPlaceDict
                                                     withBindings:bindings];

                    // Process the results of the fetch request
                    FOSBackgroundOperation *newTopLevelOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *ignore) {

                        // The fetchEntityOp returns isCancelled if the entity is deleted locally
                        if (!fetchEntityOp.isCancelled && fetchEntityOp.error == nil) {

                            [newEntities addObject:fetchEntityOp.managedObjectID];
                        }
                        else if (!self.saveIndividualResults) {
                            newEntities = nil;
                            blockSelf->_error = fetchEntityOp.error;
                        }
                    }];

                    [newTopLevelOp addDependency:fetchEntityOp];

                    // Add further dependencies to finalOp (finalOp has already been queued)
                    [finalOp addDependency:newTopLevelOp];

                    [newTopLevelOps addObject:newTopLevelOp];
                }

                for (FOSOperation *nextTopLevelOp in newTopLevelOps) {
                    [self addDependency:nextTopLevelOp];
                }

                [blockSelf.restConfig.cacheManager reQueueOperation:self];
            }
        }
    }];
    
    [webProcOp addDependency:webRequest];
    
    // FinalOp is dependent on processing the results of webRequest *and*
    // processing subsequently generated FOSFetchEntityOperations of webRequest
    // (which are added to finalOp during weProcOp's processing)
    [finalOp addDependency:webProcOp];
    
    return finalOp;
}

@end
