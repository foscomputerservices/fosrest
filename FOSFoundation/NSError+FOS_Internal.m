//
//  NSError+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 5/30/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "NSError+FOS_Internal.h"
#import "NSError+FOS.h"

@implementation NSError (FOS_Internal)

+ (NSError *)errorWithMessage:(NSString *)message {
    return [self errorWithDomain:@"FOSFoundation" andMessage:message];
}

+ (NSError *)errorWithMessage:(NSString *)message forAtom:(id<FOSCompiledAtomInfo>)atom {
    NSString *msgFmt = @"ERROR : %@ - %@";
    NSString *msg = [NSString stringWithFormat:msgFmt,
                     atom.atomDescription,
                     message];

    return [self errorWithMessage:msg];
}

@end
