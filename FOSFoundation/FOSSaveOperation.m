//
//  FOSSaveOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSSaveOperation.h"
#import "FOSOperationQueue.h"
#import "FOSRESTConfig.h"

@implementation FOSSaveOperation {
    NSError *_saveError;
}

#pragma mark - NSOperation Overrides

- (NSError *)error {
    NSError *result = _saveError;

    if (result == nil) {
        // The save operation is made dependent against all ops as they're queued, but
        // in order for error recovery to work, we only check the base operation
        // for this status.
        result = _baseOperation.error;
    }

    return result;
}

- (BOOL)isCancelled {
    // The save operation is made dependent against all ops as they're queued, but
    // in order for cancellation recovery to work, we only check the base operation
    // for this status.
    BOOL result  = _baseOperation.isCancelled;

    return result;
}

- (void)main {
    [super main];

    if (self.restConfig.loginManager.isLoggedIn) {
        FOSDatabaseManager *dbMgr = self.restConfig.databaseManager;

        if (self.isCancelled) {
            FOSLogInfo(@"-------------------- ROLLBACK: Save operation was cancelled for queue group: %@ --------------------", self.groupName);

            [dbMgr.currentMOC reset];
        }
        else if (self.error != nil) {
            FOSLogError(@"-------------------- ROLLBACK: Error %@ encountered for queue group: %@ --------------------",
                  self.error, self.groupName);

            // We're calling reset here instead of rollback.
            // This fixes an issue where calling rollback seemed to try to restore an instance
            // in the following case:
            //
            // 1) Create an instance in the MOC
            // 2) Get a real NSManagedObjectID for the instance
            // 3) Delete the instance due to subsequent errors
            // 4) Rollback
            //
            // In this case it seems that the MOC was trying to restore the instance on rollback
            // when it really shouldn't have because it was actually created in this context.
            [dbMgr.currentMOC reset];
        }
        else {
            FOSLogDebug(@"SAVE: Save operation was initiated for queue group: %@", self.groupName);

            // We don't really do anything, all the work is done by
            // our dependencies.  So, all we need to do is to save
            // the changes to get them back to the main thread.
            NSError *error = nil;
            [dbMgr saveChanges:&error];
            _saveError = error;

            if (_saveError == nil) {
                FOSLogDebug(@"-------------------- SAVED: Save operation was completed for queue group: %@ --------------------", self.groupName);
            }
            else {
                [dbMgr.currentMOC reset];

                FOSLogError(@"-------------------- SAVE ERROR: Save operation FAILED for queue group: %@ -- %@ --------------------", self.groupName, _saveError.description);
            }
        }
    }
    else {
        FOSLogInfo(@"-------------------- SKIPPED: Save operation was skipped due to being logged out for queue group: %@ --------------------", self.groupName);
    }
}

@end
