//
//  FOSSaveOperation.m
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <FOSSaveOperation.h>
#import "FOSFoundation_Internal.h"

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
