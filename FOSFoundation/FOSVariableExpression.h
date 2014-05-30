//
//  FOSVariableExpression.h
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

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
