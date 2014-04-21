//
//  FOSNetworkStatusMonitor_FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 11/11/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSNetworkStatusMonitor.h"

@interface FOSNetworkStatusMonitor ()

/*!
 * @property forceOffline
 *
 * This is an internal property for testing online/offline mode.  By setting
 * this property to YES, it will cause the receiver to report back
 * FOSNetworkStatusNotReachable from the networkStatus property.  It will also
 * trigger the appropriate change in status notifications.
 */
@property (nonatomic, assign, getter=isForcedOffline) BOOL forceOffline;

@end
