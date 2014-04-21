//
//  FOSParseUser+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 1/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSParseUser+FOS_Internal.h"
#import "FOSParseCachedManagedObject+FOS_Internal.h"

@implementation FOSParseUser (FOS_Internal)

#pragma mark - Properties

- (NSString *)lowercaseUsername {
    return [self.username lowercaseString];
}

#pragma mark - Overrides

- (void)willSave {
    if (!self.willSaveHasRecursed) {
        FOSRESTConfig *restConfig = [FOSRESTConfig sharedInstance];

        if (!restConfig.userNamesAreCaseSensitive) {
            // We must not change self.username unless they're not equal, otherwise
            // we'll get into an infinite loop (see docs on willSave).

            // We can only update the value if the calling application already updated
            // it.  We cannot update the value if it came from the server.
            if ([self.changedValues.allKeys containsObject:@"username"] &&
                !self.markedClean &&
                ![self.username isEqualToString:self.lowercaseUsername]) {
                self.username = self.lowercaseUsername;
            }
        }
    }

    [super willSave];
}

@end
