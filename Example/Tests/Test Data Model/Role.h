//
//  Role.h
//  FOSFoundation
//
//  Created by David Hunt on 2/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <FOSFoundation/FOSParseCachedManagedObject.h>

@class User;

@interface Role : FOSParseCachedManagedObject

@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Role (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

- (void)addNotesObject:(NSManagedObject *)value;
- (void)removeNotesObject:(NSManagedObject *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
