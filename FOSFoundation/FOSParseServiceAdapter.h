//
//  FOSParseRESTAdapter.h
//  FOSFoundation
//
//  Created by David Hunt on 3/14/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FOSParseServiceAdapter : FOSBoundServiceAdapter

#pragma mark - Class Methods

+ (instancetype)adapterWithApplicationId:(NSString *)applicationid
                           andRESTAPIKey:(NSString *)restAPIKey;

#pragma mark - Initialization

- (id)initWithApplicationId:(NSString *)applicationId
              andRESTAPIKey:(NSString *)restAPIKey;

@end
