//
//  NSMutableString+FOS.h
//  FOSFoundation
//
//  Created by David Hunt on 12/27/11.
//  Copyright (c) 2011 FOS Computer Services. All rights reserved.
//

@import Foundation;

@interface NSMutableString(HtmlEscape)

- (NSMutableString *)escapeHtml;
- (void)appendStringAsCSVField:(NSString *)string;

@end

