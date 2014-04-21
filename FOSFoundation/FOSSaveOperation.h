//
//  FOSSaveOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSOperation.h"

@class FOSDatabaseManager;

@interface FOSSaveOperation : FOSOperation

/*!
 * @property baseOperation
 *
 * The single operation that is at the root of the dependency tree.
 * This operation is consulted for error/cancel information.
 */
@property (nonatomic, strong) FOSOperation *baseOperation;

@end
