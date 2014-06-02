//
//  FOSDatabaseManager.m
//  FOSFoundation
//
//  Created by David Hunt on 5/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSDatabaseManager.h"
#import "FOSMergePolicy.h"
#import "FOSOperationQueue.h"
#import "FOSRESTConfig.h"

@implementation FOSDatabaseManager {
    __weak FOSRESTConfig *_restConfig;
    NSManagedObjectContext *_mainThreadMOC;
}

#pragma mark - Public Properties

- (NSManagedObjectContext *)currentMOC {
    NSManagedObjectContext *result = nil;

    if ([NSThread isMainThread]) {
        if (_mainThreadMOC == nil) {
            _mainThreadMOC =
                [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            _mainThreadMOC.persistentStoreCoordinator = _restConfig.storeCoordinator;
            _mainThreadMOC.mergePolicy =
                [[FOSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        }

        result = _mainThreadMOC;
    }
    else {
        FOSOperationQueue *opQueue = [FOSOperationQueue currentQueue];
        NSAssert(opQueue == nil || [opQueue isKindOfClass:[FOSOperationQueue class]],
                 @"Received %@, expected FOSOperationQueue.",
                 NSStringFromClass([opQueue class]));

        result = opQueue.managedObjectContext;
    }

    return result;
}

#pragma mark - Public Methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig {
    NSParameterAssert(restConfig != nil);
    NSParameterAssert(restConfig.storeCoordinator != nil);

    if ((self = [super init]) != nil) {
        _restConfig = restConfig;
    }

    return self;
}

- (NSArray *)fetchEntitiesNamed:(NSString *)entityName {
    return [self fetchEntitiesNamed:entityName withPredicate:nil];
}

- (NSArray *)fetchEntitiesNamed:(NSString *)entityName
                  withPredicate:(NSPredicate *)predicate {
    return [self fetchEntitiesNamed:entityName
                      withPredicate:predicate
                withSortDescriptors:nil];
}

- (NSArray *)fetchEntitiesNamed:(NSString *)entityName
                  withPredicate:(NSPredicate *)predicate
            withSortDescriptors:(NSArray *)sortDescriptors {
    NSManagedObjectContext *moc = self.currentMOC;
    NSError *error = nil;
    
    NSArray *result = [self fetchEntitiesNamed:entityName
                                 withPredicate:predicate
                           withSortDescriptors:sortDescriptors
                             withObjectContext:moc
                                         error:&error];
    
    if (result == nil && error != nil) {
        NSDictionary *userInfo = @{ @"error" : error };
        NSString *msg = [NSString stringWithFormat:@"Error fetching %@: %@",
                         entityName, error.description];
        
        @throw [NSException exceptionWithName:@"DBError"
                                       reason:msg
                                     userInfo:userInfo];
    }
    
    return result;
}

- (NSArray *)fetchEntitiesNamed:(NSString *)entityName
                  withPredicate:(NSPredicate *)predicate
            withSortDescriptors:(NSArray *)sortDescriptors
              withObjectContext:(NSManagedObjectContext *)managedObjectContext
                          error:(NSError **)error {
    
    NSParameterAssert(entityName != nil);
    NSParameterAssert(entityName.length > 0);
    NSParameterAssert(managedObjectContext != nil);
    NSParameterAssert(error != nil);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if (predicate != nil) {
        [fetchRequest setPredicate:predicate];
    }

    if (sortDescriptors.count > 0) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }

    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:error];
    
    return result;
}

- (NSUInteger)countOfEntitiesNamed:(NSString *)entityName
                 matchingPredicate:(NSPredicate *)predicate {

    NSManagedObjectContext *moc = self.currentMOC;
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:moc];

    return [self countOfEntities:entity
               matchingPredicate:predicate
                 inObjectContext:moc];
}

- (NSUInteger)countOfEntities:(NSEntityDescription *)entity
            matchingPredicate:(NSPredicate *)predicate {
    return [self countOfEntities:entity
               matchingPredicate:predicate
                 inObjectContext:self.currentMOC];
}

- (NSUInteger)countOfEntities:(NSEntityDescription *)entity
            matchingPredicate:(NSPredicate *)predicate
              inObjectContext:(NSManagedObjectContext *)manageObjectContext {
    
    NSParameterAssert(entity != nil);
    NSParameterAssert(manageObjectContext != nil);

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.predicate = predicate;

    NSError *error = nil;
    NSUInteger result = [manageObjectContext countForFetchRequest:fetchRequest
                                                           error:&error];

    return result;
}

- (void)saveChanges {
    NSError *error = nil;
    
    if (![self saveChanges:&error]) {
        NSString *msg = [NSString stringWithFormat:@"**** Error saving changes to database: %@",
                         error.description];
#ifdef DEBUG
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error
                                                             forKey:@"error"];

        @throw [NSException exceptionWithName:@"FOSDBSaveError"
                                       reason:msg
                                     userInfo:userInfo];
#else
        FOSLogDebug(@"%@", msg);
        [self.currentMOC rollback];
#endif
    }
}

- (BOOL)saveChanges:(NSError **)error {
    NSManagedObjectContext *moc = self.currentMOC;

    BOOL result = YES;
#ifndef NS_BLOCK_ASSERTIONS
    NSInteger saveCount = 0;
#endif
    
    // Saving can result in FOSModifiedProperty instances being created, so save until no
    // more changes remain
    do {
        if (moc.hasChanges && ![moc save:error]) {
            FOSLogError(@"Unresolved error saving changes to store: %@, %@",
                  [*error description], [*error userInfo]);
            result = NO;
        } 
        
#ifndef NS_BLOCK_ASSERTIONS
        // Let's not let this go on forever!
        NSAssert(saveCount++ < 20, @"Why cannot we finish saving changes???");
#endif
    } while (result && moc.hasChanges);
        
    return result;
}

@end
