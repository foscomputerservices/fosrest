//
//  FOSAdapterBindingParser+FOS_Internal.m
//  Pods
//
//  Created by David Hunt on 2/6/15.
//
//

#import "FOSAdapterBindingParser+FOS_Internal.h"

extern FOSAdapterBinding *parserAdapterBinding;

@implementation FOSAdapterBindingParser (FOS_Internal)

+ (FOSAdapterBinding *)capturedParsedAdapterBinding {
    FOSAdapterBinding *result = parserAdapterBinding;

    // Clear the binding, it's one-shot
    parserAdapterBinding = nil;

    return result;
}

@end