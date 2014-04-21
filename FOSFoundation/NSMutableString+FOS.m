//
//  NSMutableString+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 12/27/11.
//  Copyright (c) 2011 FOS Computer Services. All rights reserved.
//

#import "NSMutableString+FOS.h"

@implementation NSMutableString(FOS)

- (NSMutableString *)escapeHtml {
    
    [self replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [self length])];
    
    return self;
}

- (void)appendStringAsCSVField:(NSString *)string {

    return [self appendString:[self _csvFieldForString:string]];
}

#pragma mark - Private Methods

- (NSString *)_csvFieldForString:(NSString *)string {

    if (string == nil) {
        string = @"";
    }

    NSCharacterSet *quoteCharSet = [NSCharacterSet characterSetWithCharactersInString:@" ,\r\n"];

    if ([string rangeOfString:@"\""].location != NSNotFound) {
        string = [NSString stringWithFormat:@"\"%@\"", [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""]];
    }

    else if ([string rangeOfCharacterFromSet:quoteCharSet].location != NSNotFound) {
        string = [NSString stringWithFormat:@"\"%@\"", string];
    }

    return string;
}

@end
