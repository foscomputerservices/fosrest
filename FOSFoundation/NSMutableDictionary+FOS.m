//
//  NSMutableDictionary+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "NSMutableDictionary+FOS.h"

@implementation NSMutableDictionary (JSON)

#pragma mark - Private Methods

- (NSNumber *)_jsonDateForNSDate:(NSDate *)date {
    return [NSNumber numberWithLong:(long)date.timeIntervalSince1970];
}

#pragma mark - Public Methods

- (void)setJSONObject:(id)obj forKey:(NSString *)key {
    [self setJSONObject:obj forKey:key usingNullValue:[NSNull null]];
}

- (void)setJSONObject:(id)obj forKey:(NSString *)key usingNullValue:(id)nullVal {
    NSParameterAssert(key != nil);
    
    if (obj == nil) {
        obj = nullVal;
    }
    else if ([obj isKindOfClass:[NSDate class]]) {
        obj = [self _jsonDateForNSDate:(NSDate *)obj];
    }
    
    [self setObject:obj forKey:key];
}

@end
