//
//  NSAttributeDescription+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 4/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "NSAttributeDescription+FOS_Internal.h"

@implementation NSAttributeDescription (FOS_Internal)

+ (BOOL)isCMOProperty:(NSString *)propertyName {
    BOOL result = NO;

    // TODO : Consider generating this list from Obj-C meta data.
    if (
        // FOSManagedObject
        [propertyName isEqualToString:@"createdAt"] ||
        [propertyName isEqualToString:@"lastModifiedAt"] ||
        [propertyName isEqualToString:@"willSaveHasRecursed"] ||

        // FOSCachedManagedObject
        [propertyName isEqualToString:@"updatedWithServerAt"] ||
        [propertyName isEqualToString:@"markedClean"] ||
        [propertyName isEqualToString:@"hasRelationshipFaults"] ||
        [propertyName isEqualToString:@"hasModifiedProperties"] ||
        [propertyName isEqualToString:@"isFaultObject"] ||
        [propertyName isEqualToString:@"isLocalOnly"] ||
        [propertyName isEqualToString:@"isReadOnly"] ||
        [propertyName isEqualToString:@"isUploadable"] ||
        [propertyName isEqualToString:@"originalJsonData"] ||

        [propertyName isEqualToString:@"isDirty"] ||
        [propertyName isEqualToString:@"inhibitFaultResolution"] ||
        [propertyName isEqualToString:@"hasLocalOnlyParent"] ||
        [propertyName isEqualToString:@"isSubTreeDirty"] ||
        [propertyName isEqualToString:@"jsonIdValue"] ||
        [propertyName isEqualToString:@"updateNotificationName"] ||
        [propertyName isEqualToString:@"skipServerDelete"] ||
        [propertyName isEqualToString:@"skipServerDeleteTree"]
    ) {
        result = YES;
    }

    return result;
}

+ (BOOL)isUploadableCMOProperty:(NSString *)propertyName {
    NSParameterAssert([self isCMOProperty:propertyName]);

    BOOL result = NO;

    if (
        // FOSManagedObject
        [propertyName isEqualToString:@"createdAt"] ||
        [propertyName isEqualToString:@"lastModifiedAt"]
    ) {
        result = YES;
    }

    return result;
}

- (BOOL)isCMOProperty {
    BOOL result = [[self class] isCMOProperty:self.name];

    return result;
}

- (BOOL)isUploadableCMOProperty {
    BOOL result = [[self class] isUploadableCMOProperty:self.name];

    return result;
}

@end
