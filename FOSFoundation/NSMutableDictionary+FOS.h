//
//  NSMutableDictionary+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FOS)

- (void)setJSONObject:(id)obj forKey:(NSString *)key;
- (void)setJSONObject:(id)obj forKey:(NSString *)key usingNullValue:(id)nullVal;

@end
