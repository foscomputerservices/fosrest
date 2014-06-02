//
//  NSDate+FOS.m
//
//  Created by David Hunt on 7/4/11.
//  Copyright 2011 FOS Computer Services. All rights reserved.
//

#import "NSDate+FOS.h"


@implementation NSDate(FOS)


+ (NSDate *)utcDate {
    
    return [NSDate date];
}

+ (NSDate *)dateInUTCTimeZoneAtMidnight {
    NSDate *utcNow = [NSDate utcDate];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:utcNow];
    [dateComponents setHour:-6];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *strippedDate = [calendar dateFromComponents:dateComponents];
    
    return strippedDate;
}

+ (NSDate *)dateInLocalTimeZoneAtMidnight {
    NSDate *utcMidnight = [NSDate dateInUTCTimeZoneAtMidnight];
    
    NSTimeInterval localTimeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSDate *localDate = [utcMidnight dateByAddingTimeInterval:localTimeZoneOffset];
        
    return localDate;
}

- (NSDate *)dateFromBeginningOfDayAndAddHours:(NSInteger)hours {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    // Pull out only the pieces that we need from the given date
    NSDateComponents *dateComps =
    [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                fromDate:self];

    // We've pull off the hour/minute components, so now we
    // have just the date
    NSDate *result = [calendar dateFromComponents:dateComps];

    // Now add the number of hours that they requested
    if (hours != 0) {
        result = [result dateByAddingTimeInterval:hours * (60 * 60)];
    }

    return result;
}

@end
