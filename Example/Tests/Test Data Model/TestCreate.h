//
//  TestCreate.h
//  FOSFoundation
//
//  Created by David Hunt on 3/21/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

@import Foundation;
#import <FOSFoundation/FOSParseCachedManagedObject.h>

@class Note, User;

@interface TestCreate : FOSParseCachedManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) User *user;
@end

@interface TestCreate (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
