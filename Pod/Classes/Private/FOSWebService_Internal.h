//
//  FOSWebService_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FOSFoundation_Internal.h"

@class FOSRESTConfig;
@protocol FOSProcessServiceRequest;

/*!
 * @class FOSWebService
 *
 * FOSWebService implements the ability to communicate with the web service.
 *
 * @discussion
 *
 * It should be noted that all handler callbacks are
 * *** NOT *** guaranteed to be executed on the main thread
 * (in fact, will probably never be).
 */
@interface FOSWebService : NSObject<FOSProcessServiceRequest>

@end
