//
//  FOSDatabaseManager.h
//  FOSFoundation
//
//  Created by David Hunt on 5/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FOSRESTConfig;

@interface FOSDatabaseManager : NSObject

#pragma mark - Properties
@property (nonatomic, readonly) NSManagedObjectContext *currentMOC;

#pragma mark - Public Methods

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig;

// These can be called from any thread as long as the managedObjectContext
// is valid for the calling thread (e.g. main thread, or queue thread).
- (NSArray *)fetchEntitiesNamed:(NSString *)entityName;
- (NSArray *)fetchEntitiesNamed:(NSString *)entityName
                  withPredicate:(NSPredicate *)predicate;
- (NSArray *)fetchEntitiesNamed:(NSString *)entityName
                  withPredicate:(NSPredicate *)predicate
            withSortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchEntitiesNamed:(NSString *)entityName
                  withPredicate:(NSPredicate *)predicate
            withSortDescriptors:(NSArray *)sortDescriptors
              withObjectContext:(NSManagedObjectContext *)managedObjectContext
                          error:(NSError **)error;

- (NSUInteger)countOfEntitiesNamed:(NSString *)entityName
                 matchingPredicate:(NSPredicate *)predicate;
- (NSUInteger)countOfEntities:(NSEntityDescription *)entity
            matchingPredicate:(NSPredicate *)predicate;
- (NSUInteger)countOfEntities:(NSEntityDescription *)entity
            matchingPredicate:(NSPredicate *)predicate
              inObjectContext:(NSManagedObjectContext *)manageObjectContext;

- (void)saveChanges;
- (BOOL)saveChanges:(NSError **)error;

@end
