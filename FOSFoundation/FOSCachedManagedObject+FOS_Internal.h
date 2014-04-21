//
//  FOSCachedManagedObject+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 12/29/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSCachedManagedObject.h"

@interface FOSCachedManagedObject(FOS_Internal)

+ (NSString *)entityName;

/*!
 * @method entityDescription
 *
 * Returns the NSEntityDescription associated with the
 * receiver's class.
 */
+ (NSEntityDescription *)entityDescription;

/*!
 * @method initSkippingReadOnlyCheck
 *
 * An internal initializer that allows skipping the
 * static table check so that static table instances
 * can be created when being pulled from the server.
 */
- (id)initSkippingReadOnlyCheck;

@end
