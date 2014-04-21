//
//  FOSTimeFilter.m
//  FOSFoundation
//
//  Created by David Hunt on 12/26/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSTimeFilter.h"

@implementation FOSTimeFilter

- (NSString *)description {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterMediumStyle;
    dateFormatter.timeStyle = kCFDateFormatterMediumStyle;

    NSMutableString *result = [NSMutableString stringWithFormat:@"{ { super = %@ }, startTimeMin = %@, startTimeMax = %@, endTimeMin = %@, endTimeMax = %@ }",
                               [super description],
                               self.startTimeMin ? [dateFormatter stringFromDate:self.startTimeMin] : @"<null>",
                               self.startTimeMax ? [dateFormatter stringFromDate:self.startTimeMax] : @"<null>",
                               self.endTimeMin ? [dateFormatter stringFromDate:self.endTimeMin] : @"<null>",
                               self.endTimeMax ? [dateFormatter stringFromDate:self.endTimeMax] : @"<null>"
                               ];

    return result;
}

@end
