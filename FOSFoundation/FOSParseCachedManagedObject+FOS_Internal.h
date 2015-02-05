//
//  FOSParseCachedManagedObject+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSFoundation_Internal.h"

@interface FOSParseCachedManagedObject (FOS_Internal)

+ (NSString *)jsonOrderProp;

+ (id<NSObject>)parseJsonValueForDate:(NSDate *)date;

@end
