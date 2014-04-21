//
//  NSObject+Tests.m
//  FOSFoundation
//
//  Created by David Hunt on 1/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "NSObject+Tests.h"

@implementation NSObject (Tests)

+ (User *)loggedInUser {
    return (User *)[FOSRESTConfig sharedInstance].loginManager.loggedInUser;
}

- (User *)loggedInUser {
    return [[self class] loggedInUser];
}

@end
