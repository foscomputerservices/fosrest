//
//  FOSValueTransformer.h
//  FOSREST
//
//  Created by David Hunt on 9/2/14.
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

/*!
 * @protocol FOSValueTransformer
 *
 * Provides a protocol for a two-way binding protocol between a string
 * and any artitrary type.
 *
 * This protocol si much the same as NSValueTransformer
 * except that it's meant to be added to an NSValueTransformer that's
 * bound to a CoreData attribute to allow the attribute to be transferred
 * back-and-forth to the web service.  Additionally, an error handling
 * mechanism is provided.
 *
 * The 'local value' referred to in this protocol is meant to be of the
 * same type as is returned from NSValueTransformer::reverseTransformedValue or
 * that is provided to NSValueTransformer::transformedValue.
 */
@protocol FOSValueTransformer <NSObject>

@required

/*!
 * @method webServiceValueFromLocalValue:error:
 *
 * Converts a local value to a string that can be sent to the web service.
 */
- (NSString *)webServiceValueFromLocalValue:(id)localValue error:(NSError **)error;

/*!
 * @method localValueFromWebServiceValue:error:
 *
 * Converts a web service response string to a local value.
 */
- (id)localValueFromWebServiceValue:(NSString *)webServiceValue
                              error:(NSError **)error;

@end