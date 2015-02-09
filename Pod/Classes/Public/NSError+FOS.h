//
//  NSError+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 5/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@import Foundation;

@interface NSError (FOS)

+ (NSError *)errorWithDomain:(NSString *)domain
                  andMessage:(NSString *)userError;

+ (NSError *)errorWithDomain:(NSString *)domain
                   errorCode:(NSInteger)errorCode
                  andMessage:(NSString *)userError;

+ (NSError *)errorWithDomain:(NSString *)domain
                     message:(NSString *)userError
                 andUserInfo:(NSDictionary *)userInfo;

+ (NSError *)errorWithDomain:(NSString *)domain
                   errorCode:(NSInteger)errorCode
                     message:(NSString *)userError
                 andUserInfo:(NSDictionary *)userInfo;

- (void)throwError;

@end
