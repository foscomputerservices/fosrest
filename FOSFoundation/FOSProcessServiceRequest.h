//
//  FOSProcessServiceRequest.h
//  FOSFoundation
//
//  Created by David Hunt on 2/11/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FOSRESTConfig;
@class FOSWebServiceRequest;

@protocol FOSProcessServiceRequest <NSObject>

- (id)initWithCacheConfig:(FOSRESTConfig *)restConfig;
- (void)queueRequest:(FOSWebServiceRequest *)request;

@end
