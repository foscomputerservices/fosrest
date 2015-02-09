//
//  NSObject+Tests.h
//  FOSFoundation
//
//  Created by David Hunt on 1/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface NSObject (Tests)

+ (User *)loggedInUser;
- (User *)loggedInUser;

@end
