//
//  FOSLoginManagerTests.h
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSLoginManager.h>
#import <FOSRESTConfig.h>
#import <XCTest/XCTest.h>
#import "User.h"

typedef void (^TestCallBack)();

@interface FOSLoginManagerTests : XCTestCase

+ (FOSNetworkStatusMonitor *)networkStatusMonitor;
+ (void)setupStandardWebServiceConfig;
+ (void)setupStandardWebServiceConfigWithOptions:(FOSRESTConfigOptions)configOptions;
+ (void)tearDownWebService;

+ (void)setupStandardWebServiceConfigAndLogInWithOptions:(FOSRESTConfigOptions)configOptions;
+ (void)setupStandardWebServiceConfigAndLogInWithOptions:(FOSRESTConfigOptions)configOptions
                                             andCallback:(TestCallBack)handler;
+ (void)tearDownWebServiceAndLogOut;

@end
