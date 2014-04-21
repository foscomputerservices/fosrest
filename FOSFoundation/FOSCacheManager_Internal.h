//
//  FOSCacheManager_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@class FOSWebService;
@protocol FOSServiceRequestProcessor;

@interface FOSCacheManager(Internal)

- (id<FOSServiceRequestProcessor>)serviceRequestProcessor;

@end