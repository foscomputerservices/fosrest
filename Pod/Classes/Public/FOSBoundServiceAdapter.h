//
//  FOSBoundServiceAdapter.h
//  FOSREST
//
//  Created by David Hunt on 3/21/14.
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

#import <Foundation/Foundation.h>
#import <fosrest/FOSRESTServiceAdapter.h>

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
 * The default implementation of these methods will throw the "FOSREST_Internal.h"_MustOverride exception.
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
 * @method serverDateFormats
 *
 * An array of date format strings to provide to NSDateFormatter.dateFormat to use for
 * [en|de]coding dates to/from the server.
 *
 * Subclasses must override this method and provide their format.
 *
 * If more than one date format is available, an NSAttributeDesciption must choose
 * which formatter by specifying a dateFormatIndex key in the userInfo dictionary
 * with an integer indicating the index of the formatter to use.
*/
+ (NSArray *)serverDateFormats;

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
