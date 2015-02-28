//
//  WidgetSearchOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
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

#import "WidgetSearchOperation.h"
#import "Widget.h"

@implementation WidgetSearchOperation

- (Class)managedClass {
    return [Widget class];
}

- (NSString *)dslQuery {
    NSParameterAssert(self.widgetName != nil ||
                      self.uid != nil);

    // DSLQUERY = {"user" : {"__type" : "Pointer", "className" : "_User", "objectId" : "EcpQ2bE3fx"}}
    NSMutableString *result = [NSMutableString stringWithString:@"{"];
    if (self.uid != nil) {
        [result appendFormat:@"{ \"user\" : {\"__type\" : \"Pointer\", \"className\" : \"_User\", \"objectId\" : \"%@\"} }", self.uid];
    }
    else {
        [result appendFormat:@"%@\"name\" : \"%@\"",
         self.uid == nil ? @"" : @", ",
         self.widgetName];
    }

    [result appendString:@"}"];

    return result;
}

@end
