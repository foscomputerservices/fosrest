//
//  FOSValueTransformer.h
//  FOSFoundation
//
//  Created by David Hunt on 9/2/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
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