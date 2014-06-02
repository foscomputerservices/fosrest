//
//  NSAttributeDescription+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "NSAttributeDescription+FOS.h"

@implementation NSAttributeDescription (FOS)

- (NSString *)jsonLogInProp {
    NSString *result = self.userInfo[@"jsonLogInProp"];

    return result;
}

- (NSString *)jsonLogOutProp {
    NSString *result = self.userInfo[@"jsonLogOutProp"];

    return result;
}

@end
