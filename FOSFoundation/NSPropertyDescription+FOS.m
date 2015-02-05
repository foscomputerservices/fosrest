//
//  NSPropertyDescription+FOS.m
//  FOSFoundation
//
//  Created by David Hunt on 9/3/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "NSPropertyDescription+FOS.h"
#import "FOSFoundation_Internal.h"

@implementation NSPropertyDescription (FOS)

#pragma mark - Localization Properties

- (NSString *)localizedName {
    NSString *result = nil;

    NSManagedObjectModel *mom = self.entity.managedObjectModel;
    NSDictionary *locDict = mom.localizationDictionary;
    NSString *dictKey = [NSString stringWithFormat:@"Property/%@", self.name];

    result = locDict[dictKey];

    if (result == nil) {
        FOSLogPedantic(@"Missing translation for property: %@", self.name);
    }

    return result;
}

@end
