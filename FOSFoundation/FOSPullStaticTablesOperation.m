//
//  FOSPullStaticTablesOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 4/23/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSPullStaticTablesOperation.h"
#import "FOSStaticTableSearchOperation.h"
#import "FOSPullStaticTablesOperation+FOS_Internal.h"

static BOOL _staticTableListInitialized = NO;
static NSMutableArray *_uncheckedStaticTables = nil;
static NSMutableArray *_checkingStaticTables = nil;

@implementation FOSPullStaticTablesOperation

+ (void)initialize {
    if (_uncheckedStaticTables == nil) {
        _uncheckedStaticTables = [[NSMutableArray alloc] initWithCapacity:5];
    }

    if (_checkingStaticTables == nil) {
        _checkingStaticTables = [[NSMutableArray alloc] initWithCapacity:5];
    }
}

#pragma mark - Initialization

- (id)init {
    return [self initResettingProcessedTables:NO];
}

- (id)initResettingProcessedTables:(BOOL)resetTables {
    if ((self = [super init]) != nil) {
        @synchronized(_uncheckedStaticTables) {
            [[self class] _initStaticTablesList:resetTables managedObjectContext:self.managedObjectContext];

            for (NSEntityDescription *nextEntity in _uncheckedStaticTables) {

                // If someone else is already checking, skip it
                if ([_checkingStaticTables containsObject:nextEntity]) {
                    continue;
                }

                // TODO : Support paging.
                FOSStaticTableSearchOperation *searchOp = [[FOSStaticTableSearchOperation alloc] init];
                searchOp.staticTableClass = NSClassFromString(nextEntity.managedObjectClassName);
                [searchOp finalizeDependencies];

                FOSBackgroundOperation *finalOp = [FOSBackgroundOperation backgroundOperationWithRecoverableRequest:^FOSRecoveryOption(BOOL cancelled, NSError *error) {

                    // Remove outdated entries that are no longer available on the server
                    if (!searchOp.isCancelled && error == nil) {

                        Class tableClass = searchOp.staticTableClass;
                        NSArray *existingInstances = [tableClass fetchAll];

                        NSMutableSet *idsToRemove =
                            [NSMutableSet setWithArray:[existingInstances valueForKeyPath:@"objectID"]];
                        NSSet *serverIDs = [searchOp.results valueForKeyPath:@"objectID"];

                        [idsToRemove minusSet:serverIDs];

                        NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;

                        // The remaining ids are no longer available on the server
                        for (NSManagedObjectID *deletedCMOID in idsToRemove) {
                            FOSCachedManagedObject *deletedCMO =
                                (FOSCachedManagedObject *)[moc objectWithID:deletedCMOID];
                            
                            // No need to attempt to delete it from the server
                            deletedCMO.skipServerDelete = YES;
                            
                            [moc deleteObject:deletedCMO];
                        }
                    }

                    // Any canceled operation is just one that we can skip
                    return error == nil ? FOSRecoveryOption_Recovered : FOSRecoveryOption_NoRecovery;
                }];
                
                [finalOp addDependency:searchOp];
                [self addDependency:finalOp];
                
                [_checkingStaticTables addObject:nextEntity];
            }
        }
    }

    return self;
}

#pragma mark - Public Methods

- (void)commitProcessedTables {

    @synchronized(_uncheckedStaticTables) {
        for (NSEntityDescription *nextEntity in _checkingStaticTables) {
            [_uncheckedStaticTables removeObject:nextEntity];
        }

        [_checkingStaticTables removeAllObjects];
    }
}

- (void)rollbackProcessedTables {
    @synchronized(_uncheckedStaticTables) {
        [_checkingStaticTables removeAllObjects];
    }
}

#pragma mark - Private Methods

// NOTE: Lock _uncheckedStaticTables around this call!
+ (void)_initStaticTablesList:(BOOL)resetTables managedObjectContext:(NSManagedObjectContext *)moc {
    if (resetTables) {
        _staticTableListInitialized = NO;
        [_uncheckedStaticTables removeAllObjects];
        [_checkingStaticTables removeAllObjects];
    }

    if (!_staticTableListInitialized) {
        NSPersistentStoreCoordinator *psc = moc.persistentStoreCoordinator;
        NSManagedObjectModel *model = psc.managedObjectModel;

        NSPredicate *staticEntityPred = [NSPredicate predicateWithFormat:@"isStaticTableEntity == YES"];
        NSArray *staticTableEntities = [model.entities filteredArrayUsingPredicate:staticEntityPred];

        [_uncheckedStaticTables addObjectsFromArray:staticTableEntities];
        _staticTableListInitialized = YES;
    }
}

@end
