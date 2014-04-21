//
//  NSAttributeDescription+FOSFoundation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

/*!
 * @category NSAttributeDescription (FOS)
 *
 * This category provides access to key-value pairs
 * provided in the NSAttributeDescription userInfo
 * NSDictionary.  The names of the properties in this
 * interface correspond directly to key names that
 * are to be provided in the userInfo dictionary.
 *
 * Normally these values are set in the database
 * model modified using Xcode's database modeling
 * tools.
 */
@interface NSAttributeDescription (FOS)

/*!
 * @property jsonLogInProp
 *
 * The name of a key in the JSON that identifies the
 * value to be used for the corresponding attribute
 * in the object model for a server login request.
 *
 * @return
 *
 * Returns nil if there is no corresponding key in
 * the data model.
 */
@property (nonatomic, readonly) NSString *jsonLogInProp;

/*!
 * @property jsonLogOutProp
 *
 * The name of a key in the JSON that identifies the
 * value to be used for the corresponding attribute
 * in the object model for a server log out request.
 *
 * @return
 *
 * Returns nil if there is no corresponding key in
 * the data model.
 */
@property (nonatomic, readonly) NSString *jsonLogOutProp;

@end
