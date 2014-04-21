//
//  NSAttributeDescription+FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 4/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSAttributeDescription (FOS_Internal)

+ (BOOL)isCMOProperty:(NSString *)propertyName;
+ (BOOL)isUploadableCMOProperty:(NSString *)propertyName;

@property (nonatomic, readonly) BOOL isCMOProperty;
@property (nonatomic, readonly) BOOL isUploadableCMOProperty;

@end
