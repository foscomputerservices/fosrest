//
//  WidgetSearchOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "WidgetSearchOperation.h"
#import "Widget.h"

@implementation WidgetSearchOperation

- (Class)managedClass {
    return [Widget class];
}

- (NSString *)dslQuery {
    NSParameterAssert(self.name != nil ||
                      self.uid != nil);

    // DSLQUERY = {"user" : {"__type" : "Pointer", "className" : "_User", "objectId" : "EcpQ2bE3fx"}}
    NSMutableString *result = [NSMutableString stringWithString:@"{"];
    if (self.uid != nil) {
        [result appendFormat:@"{ \"user\" : {\"__type\" : \"Pointer\", \"className\" : \"_User\", \"objectId\" : \"%@\"} }", self.uid];
    }
    else {
        [result appendFormat:@"%@\"name\" : \"%@\"",
         self.uid == nil ? @"" : @", ",
         self.name];
    }

    [result appendString:@"}"];

    return result;
}

@end
