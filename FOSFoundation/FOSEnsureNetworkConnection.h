//
//  FOSEnsureNetworkConnection.h
//  FOSFoundation
//
//  Created by David Hunt on 6/16/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

/*!
 * @class FOSEnsureNetworkConnection
 *
 * An operation that cancels itself if the network is not available
 * when main is called.
 */
@interface FOSEnsureNetworkConnection : FOSOperation

@end
