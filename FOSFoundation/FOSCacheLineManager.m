//
//  FOSCacheLineManager.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSCacheLineManager.h"
#import "FOSCachedManagedObject.h"
#import "FOSRESTConfig.h"
#import "FOSDatabaseManager.h"
#import "FOSSearchOperation.h"
#import "FOSFetchToManyRelationshipOperation.h"

@implementation FOSCacheLineManager {
    NSArray *_orderedManagedEntityClasses;
}

#pragma mark - Initialization methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig
  forManagedEntityClasses:(NSSet *)managedEntityClasses {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(managedEntityClasses != nil);
    NSParameterAssert(managedEntityClasses.count > 0);

    if ((self = [super init]) != nil) {
        _restConfig = restConfig;

        _managedEntityClasses = managedEntityClasses;
    }

    return self;
}

#pragma mark - FOSCacheLineManager methods

- (NSArray *)dependencyOrderedManagedEntityClasses {
    @synchronized(self) {
        if (_orderedManagedEntityClasses == nil) {
            
            NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES comparator:^NSComparisonResult(Class class1, Class class2) {

                NSEntityDescription *entity1 = [class1 entityDescription];
                NSSet *flattenedRels1 = entity1.flattenedOwnershipRelationships;

                NSEntityDescription *entity2 = [class2 entityDescription];
                NSSet *flattenedRels2 = entity2.flattenedOwnershipRelationships;

                NSComparisonResult result = NSOrderedSame;

                if (flattenedRels1.count > flattenedRels2.count) {
                    result = NSOrderedDescending;
                }
                else if (flattenedRels1.count < flattenedRels2.count) {
                    result = NSOrderedAscending;
                }

//                for (NSRelationshipDescription *nextRel1 in flattendRels1) {
//                    Class relClass = NSClassFromString(nextRel1.entity.managedObjectClassName);
//
//                    if ([relClass isSubclassOfClass:class2]) {
//                        result = NSOrderedAscending;
//                        break;
//                    }
//                }
//
//                if (result == NSOrderedSame) {
//                    NSEntityDescription *entity2 = [class2 entityDescription];
//                    NSSet *flattenedRels2 = entity2.flattenedOwnershipRelationships;
//
//                    for (NSRelationshipDescription *nextRel2 in flattenedRels2) {
//                        Class relClass = NSClassFromString(nextRel2.entity.managedObjectClassName);
//
//                        if ([relClass isSubclassOfClass:class1]) {
//                            result = NSOrderedDescending;
//                            break;
//                        }
//                    }
//                }

                return result;
            }];

            _orderedManagedEntityClasses = [_managedEntityClasses sortedArrayUsingDescriptors:@[sortDesc]];
        }

        return _orderedManagedEntityClasses;
    }
}

+ (NSString *)faultsResolvedNotificationName {
    NSString *result = [NSString stringWithFormat:@"%@_FaultsResolved",
                        NSStringFromClass([self class])];

    return result;
}

- (FOSOperation *)pushChangesToEntity:(FOSCachedManagedObject *)changedEntity {
    NSParameterAssert(changedEntity != nil);
    NSParameterAssert(changedEntity.isDirty);
    NSParameterAssert(changedEntity.allReferencesHaveBeenUploadedToServer);
    NSParameterAssert(changedEntity.isUploadable);
    NSParameterAssert(!changedEntity.isFaultObject);
//    NSParameterAssert([changedEntity isKindOfClass:self.managedEntityClass]);

    FOSOperation *result = nil;

    FOSWebServiceRequest *request = nil;
    NSString *logType = nil;
    if (!changedEntity.hasBeenUploadedToServer) {
        logType = @"Create";
        request = [changedEntity.entity jsonCreateRequestForObject:changedEntity];

        if (request == nil) {
            NSString *msg = NSLocalizedString(@"Missing 'jsonCreateEndPoint' specification on entity '%@'.", @"FOSMissing_jsonCreateEndPoint");

            [NSException raise:@"FOSMissing_jsonCreateEndPoint" format:msg,
             changedEntity.entity.name];
        }
    }
    else {
        logType = @"Update";
        request = [changedEntity.entity jsonUpdateRequestForObject:changedEntity];

        if (request == nil && changedEntity.entity.jsonUpdateEndPoint.length == 0) {
            NSString *msg = NSLocalizedString(@"Missing 'jsonUpdateEndPoint' specification on entity '%@'.", @"FOSMissing_jsonUpdateEndPoint");

            [NSException raise:@"FOSMissing_jsonUpdateEndPoint" format:msg,
             changedEntity.entity.name];
        }

        // There wasn't really anything to be done.
        else {
            [changedEntity markClean];
        }
    }

    __block FOSCacheLineManager *blockSelf = self;

    FOSBackgroundOperation *finishOp = [FOSBackgroundOperation backgroundOperationWithRequest:^(BOOL isCancelled, NSError *error) {
        if (request == nil) {
            // Nothing to do
        }
        else if (!isCancelled && request.error == nil) {
            // Since we're multi-threaded, the user could have deleted the object by now
            NSManagedObjectContext *moc = blockSelf->_restConfig.databaseManager.currentMOC;
            FOSCachedManagedObject *dbObj = (FOSCachedManagedObject *)[moc objectWithID:changedEntity.objectID];
            if (dbObj != nil) {

                if (!dbObj.hasBeenUploadedToServer) {
                    FOSJsonId newId = [dbObj.entity jsonIdFromJSONFragment:request.jsonResult];

                    if (newId == nil) {
                        NSString *msg = NSLocalizedString(@"Did not receive a unique id from the web service afer creating entity '%@'.", @"FOSMissing_WebServiceId");

                        [NSException raise:@"FOSMissing_WebServiceId" format:msg,
                         changedEntity.entity.name];
                    }

#ifdef DEBUG
                    // There shouldn't already be an entity with this id
                    FOSCachedManagedObject *otherCMO = [[changedEntity class] fetchWithId:newId];
                    NSAssert(otherCMO == nil || [otherCMO.objectID isEqual:changedEntity.objectID],
                             @"Duplicate %@ instance with id %@!!!",
                             [[changedEntity class] description], (NSString *)newId);
#endif

                    [dbObj setValue:newId forKeyPath:dbObj.entity.idProperty];
                }

                [dbObj markClean];

                // NOTE: We skip saving users here as they're going to go away and be brought
                //       back down during the login process.
                //
                // TODO: Having this specialized check here seems like there needs to be some
                //       refactoring.
                if (![dbObj isKindOfClass:[FOSUser class]]) {
                    // This needs to be saved *now*, otherwise we might lose the server id and
                    // that *will* cause duplication.  Thus, we *do not* wait to save until
                    // this set of operations is complete.
                    NSError *saveError = nil;
                    if (![blockSelf->_restConfig.databaseManager saveChanges:&saveError]) {
                        NSString *msg = [NSString stringWithFormat:@"Encountered error saving identity changes for an entity of type %@: %@", dbObj.entity.name, saveError.description];

                        NSException *e = [NSException exceptionWithName:@"FOSFoundation_IdentityStore"
                                                                 reason:msg
                                                               userInfo:@{ @"error" : saveError }];

                        @throw e;
                    }
                }
            }

            NSLog(@"%@ succeeded for entity '%@ (%@)'.",
                  logType, changedEntity.entity.name, [dbObj jsonIdValue]);
        }
        else if (isCancelled) {
            NSLog(@"%@ was cancelled for entity '%@'", logType, changedEntity.entity.name);
        }
        else {
            NSLog(@"%@ failed for entity '%@': %@", logType, changedEntity.entity.name,
                  request.error.description);
        }
    }];

    if (request != nil) {
        [finishOp addDependency:request];
    }

    result = finishOp;

    return result;
}

@end
