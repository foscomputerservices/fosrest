//
//  FOSManagedObject.h
//
//  Created by David Hunt on 9/27/11.
//  Copyright 2011 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface FOSManagedObject : NSManagedObject<NSCopying>

#pragma mark - Public Properties

// NOTE: If any properties are added, add them to the skip list
//       in NSAttributeDescription's +isCMOProperty: impl.
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *lastModifiedAt;
@property (nonatomic, readonly) BOOL willSaveHasRecursed;

/*!
 * @property isReadOnly
 *
 * Determines if it is allowable to modify the receiver.
 *
 * It combines the receiver's isLocalOnly property, the
 * receiver's entity.jsonIsStaticTableEntity property along
 * with allowing subclasses to add their own logic.
 *
 * @discussion
 *
 * Subclasses that override this property should consult
 * [super isReadOnly] first and then add their own
 * logic if YES is returned.
 */
@property (nonatomic, readonly) BOOL isReadOnly;

@end
