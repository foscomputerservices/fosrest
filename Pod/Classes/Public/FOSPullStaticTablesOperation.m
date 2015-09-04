//
//  FOSPullStaticTablesOperation.m
//  FOSRest
//
//  Created by David Hunt on 4/23/13.
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

#import <FOSPullStaticTablesOperation.h>
#import "FOSREST_Internal.h"

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
                        NSSet *serverIDs = searchOp.results;

                        if (serverIDs != nil) {
                            [idsToRemove minusSet:serverIDs];
                        }

                        NSManagedObjectContext *moc = [FOSRESTConfig sharedInstance].databaseManager.currentMOC;

                        [moc performBlockAndWait:^{
                            // The remaining ids are no longer available on the server
                            for (NSManagedObjectID *deletedCMOID in idsToRemove) {
                                FOSCachedManagedObject *deletedCMO =
                                    (FOSCachedManagedObject *)[moc objectWithID:deletedCMOID];

                                // No need to attempt to delete it from the server
                                deletedCMO.skipServerDelete = YES;

                                [moc deleteObject:deletedCMO];
                            }
                        }];
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
