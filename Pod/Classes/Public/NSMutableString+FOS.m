//
//  NSMutableString+FOS.m
//  FOSRest
//
//  Created by David Hunt on 12/27/11.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <NSMutableString+FOS.h>

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
