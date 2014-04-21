//
//  NSStringExtensions.m
//
//  Created by David Hunt on 5/16/11.
//  Copyright 2011 FOS Computer Services. All rights reserved.
//

#import "NSString+FOS.h"


@implementation NSString (FOS)

- (NSString *)sentenceCapitalizedString {
    
    NSString *result = self;
    
    if (self.length > 0) {

        NSString *firstChar = [[self substringToIndex:1] uppercaseString];
        
        if (self.length > 1) {
            
            NSString *endString = [[self substringFromIndex:1] lowercaseString];
            
            result = [firstChar stringByAppendingString:endString];
        } else {
            
            result = firstChar;
        }
    }
    
    return result;
}

- (NSString *)lowercaseFirstCharString {
    NSString *result = self;

    if (self.length > 0) {

        NSString *firstChar = [[self substringToIndex:1] lowercaseString];

        if (self.length > 1) {

            NSString *endString = [self substringFromIndex:1];

            result = [firstChar stringByAppendingString:endString];
        } else {

            result = firstChar;
        }
    }

    return result;
}

- (BOOL)containsString:(NSString *)otherString {
    NSRange range = [self rangeOfString:otherString];

    return range.location != NSNotFound;
}

@end
