//
//  NSError+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 5/30/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FOSCompiledAtom.h"

@interface NSError (FOS_Internal)

+ (NSError *)errorWithMessage:(NSString *)message;
+ (NSError *)errorWithMessage:(NSString *)message forAtom:(id<FOSCompiledAtomInfo>)atom;

@end
