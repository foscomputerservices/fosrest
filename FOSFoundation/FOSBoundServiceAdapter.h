//
//  FOSBoundServiceAdapter.h
//  FOSFoundation
//
//  Created by David Hunt on 3/21/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FOSRESTServiceAdapter;
@class FOSAdapterBinding;

/*!
 * @class FOSBoundServicesAdapter
 *
 * A partial implementation of the FOSRestServiceAdapter protocol that is driven
 * from a FOSAdapterBinding tree.
 *
 * Subclasses of @link FOSBoundServicesAdapter @/link must override and implement, at a
 * minimum, the following @link FOSRESTServiceAdapter @/link protocol methods:
 *
 *  o @link FOSRESTServiceAdapter/extractJSONError:jsonResult:responseData:userInfo:error: @/link
 *
 * The default implementation of these methods will throw the FOSFoundation_MustOverride exception.
 */
@interface FOSBoundServiceAdapter : NSObject<FOSRESTServiceAdapter>

/*!
 * @methodgroup Class Methods
 */

/*!
 * @method serviceAdapterWithBinding:
 */
+ (instancetype)serviceAdapterWithBinding:(FOSAdapterBinding *)binding;

/*!
 * @method serviceAdapterFromBindingDescription:error:
 */
+ (instancetype)serviceAdapterFromBindingDescription:(NSString *)description
                                               error:(NSError *__autoreleasing *)error;
/*!
 * @method serviceAdapterFromBindingFile:error:
 *
 * Parses the file at url to create an @link FOSAdapterBinding @/link tree
 * and then creates an instance of @link FOSBoundServiceAdapter @/link
 * and binds the compiled adapter binding.
 *
 * @discussion
 *
 * The file described by url is expected to be in ASCII format.
 */
+ (instancetype)serviceAdapterFromBindingFile:(NSURL *)url error:(NSError **)error;

/*!
 * @method serverDateFormat
 *
 * A date format string to provide to NSDateFormatter.dateFormat to use for
 * [en|de]coding dates to/from the server.
 *
 * Subclasses must override this method and provide their format.
 */
+ (NSString *)serverDateFormat;

/*!
 * @methodgroup Initialization Methods
 */

/*!
 * @method initWithBinding:
 *
 * This is the designated initializer.
 */
- (id)initWithBinding:(FOSAdapterBinding *)binding;

/*!
 * @method initFromBindingDescription:error:
 */
- (id)initFromBindingDescription:(NSString *)description error:(NSError **)error;

/*!
 * @method initWithBindingFile:
 */
- (id)initFromBindingFile:(NSURL *)url error:(NSError **)error;

@end
