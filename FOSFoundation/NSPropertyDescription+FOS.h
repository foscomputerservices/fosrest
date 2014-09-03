//
//  NSPropertyDescription+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 9/3/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPropertyDescription (FOS)

/*!
 * @methodgroup Localization Properties
 */

/*!
 * @property localizedName
 *
 * Returns the localized name for the receiver in the
 * localizationDictionary associated with the recever's NSManagedObjectModel.
 */
@property (nonatomic, readonly) NSString *localizedName;

@end
