//
//  FOSSharedBindingReference.h
//  FOSFoundation
//
//  Created by David Hunt on 3/22/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

@import Foundation;
#import <FOSFoundation/FOSCompiledAtom.h>

/*!
 * @class FOSSharedBindingReference
 *
 * A reference to an @link FOSSharedBinding @/link.
 */
@interface FOSSharedBindingReference : FOSCompiledAtom

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

/*!
 * @method referenceWithBindingType:andIdentifier:
 */
+ (instancetype)referenceWithBindingType:(NSString *)bindingType
                           andIdentifier:(NSString *)identifier;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property bindingType
 */
@property (nonatomic, strong) NSString *bindingType;

/*!
 * @property identifier
 */
@property (nonatomic, strong) NSString *identifier;

@end
