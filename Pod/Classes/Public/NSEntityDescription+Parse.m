//
//  NSEntityDescription+Parse.m
//  FOSFoundation
//
//  Created by David Hunt on 5/27/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <NSEntityDescription+Parse.h>

@implementation NSEntityDescription (Parse)

- (NSString *)parseClassName {
    NSString *result = self.name;

    if ([result isEqualToString:@"User"]) {
        result = @"_User";
    }

    return result;
}

@end
