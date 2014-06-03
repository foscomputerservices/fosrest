//
//  NSAttributeDescription+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 4/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSAttributeDescription (FOS_Internal)

+ (BOOL)isFOSAttribute:(NSString *)propertyName;
+ (BOOL)isUploadableFOSProperty:(NSString *)propertyName;

@property (nonatomic, readonly) BOOL isFOSAttribute;
@property (nonatomic, readonly) BOOL isUploadableFOSProperty;

@end
