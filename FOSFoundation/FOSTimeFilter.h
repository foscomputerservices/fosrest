//
//  FOSTimeFilter.h
//  FOSFoundation
//
//  Created by David Hunt on 12/26/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FOSTimeFilter : NSObject

@property (nonatomic, strong) NSDate *startTimeMin;
@property (nonatomic, strong) NSDate *startTimeMax;
@property (nonatomic, strong) NSDate *endTimeMin;
@property (nonatomic, strong) NSDate *endTimeMax;

@end
