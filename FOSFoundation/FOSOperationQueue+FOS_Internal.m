//
//  FOSOperationQueue+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 3/19/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSOperationQueue+FOS_Internal.h"

@implementation FOSOperationQueue (FOS_Internal)

#pragma mark - Testing Support Methods

- (void)resetMOC {
    _moc = nil;
}

@end
