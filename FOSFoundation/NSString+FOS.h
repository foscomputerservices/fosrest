//
//  NSString+FOS.h
//
//  Created by David Hunt on 5/16/11.
//  Copyright 2011 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (FOS)

- (NSString *)sentenceCapitalizedString;
- (NSString *)lowercaseFirstCharString;
- (BOOL)containsString:(NSString *)otherStr;
- (NSString *)toUnderscore;

@end
