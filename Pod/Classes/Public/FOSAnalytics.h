//
//  FOSAnalytics.h
//  FOSFoundation
//
//  Created by Administrator on 9/15/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FOSAnalytics <NSObject>

#pragma mark - Public Methods

@optional
- (void)trackApplicationLaunched:(NSString *)appVersion;

@required
- (void)trackEvent:(NSString *)eventName withData:(NSDictionary *)eventData;

@end
