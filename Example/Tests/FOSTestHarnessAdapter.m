//
//  FOSTestHarnessAdapter.m
//  FOSREST
//
//  Created by David Hunt on 10/2/14.
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

#import "FOSREST.h"
#import "FOSTestHarnessAdapter.h"

@implementation FOSTestHarnessAdapter {
    NSManagedObjectModel *_mergedObjectModel;
}

- (NSPersistentStoreCoordinator *)setupDatabaseForcingRemoval:(BOOL)forceDBRemoval error:(NSError **)error {

    if (error != nil) { *error = nil; }

    NSPersistentStoreCoordinator *result = nil;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSURL *appLibDirURL = [[fileMgr URLsForDirectory:NSLibraryDirectory
                                           inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [appLibDirURL URLByAppendingPathComponent:@"testDB.sqlite"];
    NSError *localError = nil;

    // Delete the DB between tests
    if ([fileMgr fileExistsAtPath:storeURL.path]) {
        [fileMgr removeItemAtURL:storeURL error:&localError];
    }

    if (localError == nil) {

        if (_mergedObjectModel == nil) {
            _mergedObjectModel = [[self class] _mergeModels];
        }

        @try {
            result = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_mergedObjectModel];

            if (![result addPersistentStoreWithType:NSSQLiteStoreType
                                                          configuration:nil
                                                                    URL:storeURL
                                                                options:nil
                                                                  error:&localError]) {
            }
        }
        @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat:@"Exception thrown creating store: %@",
                             exception.description];

            localError = [NSError errorWithDomain:@"FOSREST" andMessage:msg];
        }
    }

    if (localError != nil) {
        if (error != nil) {
            *error = localError;
        }

        result = nil;
    }
    
    return result;
}

+ (NSManagedObjectModel *)_mergeModels {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:2];

    // FOSREST
    NSManagedObjectModel *model = [NSBundle fosManagedObjectModel];
    [models addObject:model];

    // RESTTests
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelURL = [testBundle URLForResource:@"RESTTests" withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    [models addObject:model];

    NSManagedObjectModel *mergedModel =
        [NSManagedObjectModel modelByMergingModels:models ignoringPlaceholder:@"isPlaceholder"];

    if (mergedModel == nil) {
        FOSLogCritical(@"Unable to merge models...abort...");
        abort();
    }

    return mergedModel;
}

@end
