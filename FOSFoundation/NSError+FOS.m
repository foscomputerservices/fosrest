//
//  NSError+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 5/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "NSError+FOS.h"

@implementation NSError (FOS)

+ (NSError *)errorWithDomain:(NSString *)domain
                  andMessage:(NSString *)userError {
    return [self errorWithDomain:domain errorCode:0 message:userError andUserInfo:nil];
}

+ (NSError *)errorWithDomain:(NSString *)domain
                   errorCode:(NSInteger)errorCode
                  andMessage:(NSString *)userError {
    return [self errorWithDomain:domain errorCode:errorCode message:userError andUserInfo:nil];
}

+ (NSError *)errorWithDomain:(NSString *)domain
                     message:(NSString *)userError
                 andUserInfo:(NSDictionary *)userInfo {
    return [self errorWithDomain:domain errorCode:0 message:userError andUserInfo:userInfo];
}

+ (NSError *)errorWithDomain:(NSString *)domain
                   errorCode:(NSInteger)errorCode
                     message:(NSString *)userError
                 andUserInfo:(NSDictionary *)userInfo {

    NSMutableDictionary *finalUserInfo = userInfo == nil
        ? [NSMutableDictionary dictionaryWithCapacity:1]
        : [NSMutableDictionary dictionaryWithDictionary:userInfo];

    if (userError != nil) {
        finalUserInfo[NSLocalizedDescriptionKey] = userError;
    }
    
    NSError *error = [NSError errorWithDomain:domain
                                         code:errorCode
                                     userInfo:finalUserInfo];
    
    return error;
}

- (void)throwError {
    NSException *e = [NSException exceptionWithName:self.domain
                                             reason:self.description
                                           userInfo:self.userInfo];

    @throw e;
}

@end
