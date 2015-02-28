//
//  FOSVariableExpression.h
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
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

#import <FOSFoundation/FOSCompiledAtom.h>
#import <FOSFoundation/FOSExpression.h>

/*!
 * @class FOSVariableBinding
 *
 * Provides a mechanism to set the context for NSExpression instances, thus allowing
 * them to be evaluated on differing 'variables'.
 *
 * @discussion
 *
 * The following variables are well-known variables that are established by the runtime:
 *
 *  CMO             - The CMO
 *  ENTITY          - The entity of the CMO (same as $CMO.entity)
 *  CMOID           - The REST id of the CMO (same as $CMO.jsonIdValue)
 *  OWNERID         - The REST id of the 'owner' of the CMO
 *                  - For FOSLifecycleUpdateServerRecord && FOSLifecycleRetrieveServerRecord this
 *                  - value is the same as $CMO.owner.jsonIdValue.
 *                  - For FOSLifecyclePhaseRetrieveServerRecordRelationship, the value is the
 *                  - REST id of the owner of the relationship.
 *
 *  ATTRDESC        - The attribute currently being bound
 *  RELDESC         - The relationship currently being bound
 *
 *  ADAPTER:<name>  - A variable that is bound by @link FOSRESTServiceAdapter/valueForExpressionVariable:matched:error: @/link.
 */
@interface FOSVariableExpression : FOSCompiledAtom<FOSExpression>

/*!
 * @methodgroup Class Methods
 */
#pragma mark - Class Methods

+ (instancetype)variableExpressionWithIdentifier:(NSString *)identifier;

/*!
 * @group Public Properties
 */
#pragma mark - Public Properties

/*!
 * @property identifier
 *
 * The name of a variable that is to be bound.
 */
@property (nonatomic, strong) NSString *identifier;

@end
