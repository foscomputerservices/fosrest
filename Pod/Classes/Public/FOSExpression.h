//
//  FOSExpression.h
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FOSExpression <NSObject>

/*!
 * @group Required Methods
 */
@required

/*!
 * @method evaluateWithContext:
 *
 * Evaluates the receiver's value with the given context.
 */
- (id)evaluateWithContext:(NSDictionary *)context error:(NSError **)error;

@end
