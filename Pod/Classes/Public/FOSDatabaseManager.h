//
//  FOSDatabaseManager.h
//  FOSREST
//
//  Created by David Hunt on 5/23/12.
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

@import CoreData;
#import <fosrest/FOSCacheManager.h>

@class FOSRESTConfig;

@interface FOSDatabaseManager : NSObject

/*!
 * @methodgroup Properties
 */
#pragma mark - Properties

@property (nonatomic, readonly) NSPersistentStoreCoordinator *storeCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext *currentMOC;

/*!
 * @methodgroup Public Methods
 */
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
- (void)saveChangesToRESTServiceAndInform:(FOSBackgroundRequest)handler;
- (BOOL)saveChanges:(NSError **)error;

@end
