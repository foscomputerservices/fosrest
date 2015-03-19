//
//  NSDate+FOS.h
//
//  Created by David Hunt on 7/4/11.
//  Copyright 2011 FOS Computer Services. All rights reserved.
//

@import Foundation;

@interface NSDate(FOS)

+ (NSDate *)utcDate;
+ (NSDate *)dateInUTCTimeZoneAtMidnight;
+ (NSDate *)dateInLocalTimeZoneAtMidnight;

- (NSDate *)dateFromBeginningOfDayAndAddHours:(NSInteger)hours;

@end
