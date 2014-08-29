//
//  NSAttributeDescription+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 4/1/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "NSAttributeDescription+FOS_Internal.h"

@implementation NSAttributeDescription (FOS_Internal)

+ (BOOL)isFOSAttribute:(NSString *)propertyName {
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
        [propertyName isEqualToString:@"isSendOnly"] ||
        [propertyName isEqualToString:@"isUploadable"] ||
        [propertyName isEqualToString:@"prepareForSendOperation"] ||
        [propertyName isEqualToString:@"originalJsonData"] ||

        [propertyName isEqualToString:@"isDirty"] ||
        [propertyName isEqualToString:@"inhibitFaultResolution"] ||
        [propertyName isEqualToString:@"hasLocalOnlyParent"] ||
        [propertyName isEqualToString:@"isSubTreeDirty"] ||
        [propertyName isEqualToString:@"jsonIdValue"] ||
        [propertyName isEqualToString:@"skipServerDelete"]
    ) {
        result = YES;
    }

    return result;
}

+ (BOOL)isUploadableFOSProperty:(NSString *)propertyName {
    NSParameterAssert([self isFOSAttribute:propertyName]);

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

- (BOOL)isFOSAttribute {
    BOOL result = [[self class] isFOSAttribute:self.name];

    return result;
}

- (BOOL)isUploadableFOSProperty {
    BOOL result = [[self class] isUploadableFOSProperty:self.name];

    return result;
}

@end
