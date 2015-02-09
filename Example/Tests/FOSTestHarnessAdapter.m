//
//  FOSTestHarnessAdapter.m
//  FOSFoundation
//
//  Created by David Hunt on 10/2/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSFoundation.h"
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

            localError = [NSError errorWithDomain:@"FOSFoundation" andMessage:msg];
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

    // FOSFoundation
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
