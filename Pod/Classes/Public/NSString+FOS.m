//
//  NSStringExtensions.m
//
//  Created by David Hunt on 5/16/11.
//  Copyright 2011 FOS Computer Services. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <NSString+FOS.h>

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

- (NSString *)toUnderscore {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=[a-z])([A-Z])|([A-Z])(?=[a-z])"
                                                                           options:0 error:nil];
    NSString *result = [[regex stringByReplacingMatchesInString:self
                                                        options:0
                                                          range:NSMakeRange(0, self.length)
                                                   withTemplate:@"_$1$2"] lowercaseString];

    return result;
}

- (BOOL)containsString:(NSString *)otherString {
    NSRange range = [self rangeOfString:otherString];

    return range.location != NSNotFound;
}

- (NSString *)md5Checksum {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5],
            result[6], result[7], result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
