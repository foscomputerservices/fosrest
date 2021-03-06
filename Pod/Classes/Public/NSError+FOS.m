//
//  NSError+FOS.m
//  FOSRest
//
//  Created by David Hunt on 5/23/12.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <NSError+FOS.h>

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
