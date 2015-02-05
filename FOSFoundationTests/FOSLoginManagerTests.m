//
//  FOSLoginManagerTests.m
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@import FOSFoundation;
#import "FOSRESTConfig_FOS_Internal.h"
#import "FOSLoginManagerTests.h"
#import "FOSFoundationTests.h"
#import "FOSFoundation.h"
#import "User.h"
#import "Widget.h"
#import "FOSLoginManager_Internal.h"
#import "FOSNetworkStatusMonitor_FOS_Internal.h"
#import "FOSTestHarnessAdapter.h"
#import <stdlib.h>

#define START_CONFIG_OP \
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); \
    FOSLogInfo(@"###### Test START ######"); \
    FOSSetLogLevel(FOSLogLevelError);

#define END_CONFIG_OP { \
    FOSLogInfo(@"###### Test END ######"); \
    dispatch_semaphore_signal(semaphore); }

#define WAIT_FOR_CONFIG_OP_END { \
    CGFloat interval = 0.5f; \
    NSUInteger loopCount = 0, maxCount = (NSUInteger)((1.0f / interval) * 60.0f); \
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) { \
        if (loopCount++ < maxCount) { \
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode \
            beforeDate:[NSDate dateWithTimeIntervalSinceNow:interval]]; \
        } \
        else { \
            [NSException raise:@"FOSTesting" format:@"###### Test timed out!!! ######"]; \
        } \
    } \
}


@implementation FOSLoginManagerTests
#pragma mark - Class methods

+ (FOSNetworkStatusMonitor *)networkStatusMonitor {
    return [FOSRESTConfig sharedInstance].restServiceAdapter.networkStatusMonitor;
}

+ (void)setupStandardWebServiceConfig {
    [self setupStandardWebServiceConfigWithOptions:FOSRESTConfigAllowStaticTableModifications | FOSRESTConfigDeleteDBOnLogout];
}

+ (void)setupStandardWebServiceConfigWithOptions:(FOSRESTConfigOptions)configOptions {
    if (!FOSRESTConfig.sharedInstanceInitialized) {

        // We want all output during testing
        FOSSetLogLevel(FOSLogLevelPedantic);

        // Force to forget that we were logged in via a previous session
        [FOSLoginManager clearLoggedInUserId];

        FOSTestHarnessAdapter *adapter =
            [FOSTestHarnessAdapter adapterWithApplicationId:@"uMDqEYDMrjEFRo4vtlhx4qaFVwrvw68cPPMsVHqp"
                                              andRESTAPIKey:@"XXRQQ3349yU4AV3wsVxetNAwOpnkYVCVloPCVppu"];

        [FOSRESTConfig configWithApplicationVersion:@"1.0"
                                            options:configOptions
                                        userSubType:[User class]
                                  restServiceAdapter:adapter];

        // Block waiting for network status
        NSAssert([FOSRESTConfig sharedInstance].networkStatus != FOSNetworkStatusNotReachable,
                 @"Network unreachable.  Cannot execute tests.");
    }
}

+ (void)tearDownWebService {
    START_CONFIG_OP
    FOSSetLogLevel(FOSLogLevelInfo);

    // Reset the current MOC in case there are bad entries in it so that they don't
    // affect other tests.
    [[FOSRESTConfig sharedInstance].databaseManager.currentMOC reset];

    // Clean up some tables so that we don't have ever-growing tables
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (name BEGINSWITH %@)",
                         @"TestWidget - Don't Delete"];
    NSArray *widgets = [Widget fetchWithPredicate:pred];

    if (widgets.count > 0) {
        for (Widget *next in widgets) {
            [next.managedObjectContext deleteObject:next];
        }
    }

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL cancelled, NSError *error) {
        END_CONFIG_OP
    }];

    WAIT_FOR_CONFIG_OP_END
}

+ (void)setupStandardWebServiceConfigAndLogInWithOptions:(FOSRESTConfigOptions)configOptions {
    START_CONFIG_OP
    FOSSetLogLevel(FOSLogLevelInfo);

    [self setupStandardWebServiceConfigAndLogInWithOptions:configOptions andCallback:^{
        END_CONFIG_OP
    }];

    WAIT_FOR_CONFIG_OP_END
}

+ (void)setupStandardWebServiceConfigAndLogInWithOptions:(FOSRESTConfigOptions)configOptions andCallback:(TestCallBack)handler {
    NSParameterAssert(handler != nil);

    FOSSetLogLevel(FOSLogLevelPedantic);

    [self setupStandardWebServiceConfigWithOptions:configOptions];

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    if (!lm.isLoggedIn) {
        User *user = [self _testLoginUser];

        [lm loginUser:user loginStyle:nil handler:^(BOOL succeeded, NSError *error) {
            NSAssert(succeeded, @"Failed login: %@", error.description);

            if (succeeded) {
                NSAssert(lm.isLoggedIn, @"Not logged in???");
                NSAssert([FOSRESTConfig sharedInstance].loginManager.loggedInUser != nil,
                         @"Why not logged in user in the DB?");
            }

            handler();
        }];
    }
}

+ (void)tearDownWebServiceAndLogOut {
    [self tearDownWebService];

    START_TEST
    FOSSetLogLevel(FOSLogLevelInfo);

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    if (lm.isLoggedIn) {

        [lm logout:^(BOOL succeeded, NSError *error) {
            END_TEST
        }];
    }
    else {
        [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
            END_TEST
        }];
    }

    WAIT_FOR_TEST_END
}

#pragma mark - Test Configuration Methods

- (void)setUp {
    [super setUp];

    [[self class] setupStandardWebServiceConfig];
}

- (void)tearDown {
    // Tear-down code here.

    [[self class] tearDownWebServiceAndLogOut];

    [super tearDown];
}

#pragma mark - Login Tests

- (void)testKnownUserLogin {
    User *user = [[self class] _testLoginUser];

    // user will be destroyed before we're called back on, so copy
    // anything that we need out.
    NSString *username = [user.username copy];

    START_TEST

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    [lm loginUser:user loginStyle:nil handler:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertTrue(succeeded, @"Failed login: %@", error.description);

        if (succeeded) {
            XCTAssertTrue(lm.isLoggedIn, @"Not logged in???");
            XCTAssertTrue(lm.loggedInUserId != nil, @"No uid???");
            XCTAssertNotNil(lm.loggedInUser, @"No logged in user?");

            XCTAssertTrue([(NSString *)lm.loggedInUserId isEqualToString:(NSString *)lm.loggedInUser.uid],
                         @"Ids not equal?");

            User *loggedInUser = (User *)lm.loggedInUser;

            XCTAssertTrue([loggedInUser isKindOfClass:[FOSRESTConfig sharedInstance].userSubType],
                         @"Wrong user type.");
            XCTAssertFalse(loggedInUser.isLoginUser, @"This should be a *real* user, not a loginUser");


            XCTAssertTrue([username isEqualToString:loggedInUser.username],
                         @"Username '%@' wrong, expected '%@'", loggedInUser.username, user.username);
        }

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

- (void)testUnknownUserLogin {
    User *user = [[self class] _testLoginUnknownUser];
    START_TEST

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    [lm loginUser:user loginStyle:nil handler:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertFalse(succeeded, @"Failed succeeded???");

        if (!succeeded) {
            XCTAssertFalse(lm.isLoggedIn, @"Logged in???");
            XCTAssertNil(lm.loggedInUserId, @"Logged in id???");
            XCTAssertNil(lm.loggedInUser, @"Logged in user?");
        }

        END_TEST
    }];
    
    WAIT_FOR_TEST_END
}

// The 'bad' here is that there's a widget associated with the account that
// has a nil (schema invalid) reference to WidgetInfo in parse.  It should
// still allow us to login and we just simply don't have that reference locally.
- (void)testBadUserLogin {
    User *user = [[self class] _testBadLoginUser];
    START_TEST

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    [lm loginUser:user loginStyle:nil handler:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertTrue(succeeded, @"We should still have logged in, even though we didn't get all of our data.");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

#pragma mark - Refresh User tests

- (void)testRefreshUser {
    User *user = [[self class] _testLoginUser];
    START_TEST

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    [lm loginUser:user loginStyle:nil handler:^(BOOL succeeded, NSError *error) {
        [lm refreshLoggedInUser:^(BOOL succeeded, NSError *error) {
            XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
            XCTAssertTrue(succeeded, @"Failed: %@", error.description);
            XCTAssertTrue([FOSRESTConfig sharedInstance].loginManager.isLoggedIn, @"Not logged in???");

            END_TEST
        }];
    }];

    WAIT_FOR_TEST_END
}

//#define TEST_PWD_RESET
#ifdef TEST_PWD_RESET
- (void)testPasswordReset {
    START_TEST

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    [lm resetPasswordForResetKey:@"EMAIL" andValue:@"david@familyof7.net" handler:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertTrue(succeeded, @"Failed password reset call: %@", error.description);

        END_TEST
    }];

    WAIT_FOR_TEST_END
}

- (void)testPasswordResetBadEmail {
    START_TEST

    FOSLoginManager *lm = [FOSRESTConfig sharedInstance].loginManager;
    [lm resetPasswordForResetKey:@"EMAIL" andValue:@"bad_email@example.com" handler:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertFalse(succeeded, @"Password reset call succeeded???");

        END_TEST
    }];

    WAIT_FOR_TEST_END
}
#endif

- (void)testCreateUser {
    START_TEST

    static BOOL randomSeeded = NO;
    if (!randomSeeded) {
        srandom((unsigned)[[NSDate date] timeIntervalSince1970]);
        randomSeeded = YES;
    }

    long randomNum = random();

    User *newUser = [User createLoginUser];
    NSString *username = [NSString stringWithFormat:@"test_%li_%li", randomNum,
                          (long)[[NSDate date] timeIntervalSince1970]];
    NSString *password = @"test_pWd";
    NSString *email = [NSString stringWithFormat:@"foo_%li_%li@bar.com", randomNum,
                       (long)[[NSDate date] timeIntervalSince1970]];

    newUser.username = username;
    newUser.password = password;
    newUser.email = email;

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].loginManager createUser:newUser createStyle:nil handler:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
        XCTAssertTrue(succeeded, @"Failed???");
        XCTAssertNil(error, @"Error creating user: %@", error.description);
        XCTAssertTrue(succeeded || error != nil, @"Failed, but no error??");
        XCTAssertTrue(error == nil || !succeeded, @"Error, but succeeded???");

        if (succeeded) {
            // We must create a new instance as the previous one is now dead; createUser
            // ensures that this is true.
            User *newUser = [User createLoginUser];
            newUser.username = username;
            newUser.password = password;

            [[FOSRESTConfig sharedInstance].loginManager loginUser:newUser loginStyle:nil handler:^(BOOL succeeded, NSError *error) {
                FOSLoginManager *loginMgr = [FOSRESTConfig sharedInstance].loginManager;

                XCTAssertTrue([NSThread isMainThread], @"Wrong thread!");
                XCTAssertTrue(succeeded, @"Login failed: %@", error);
                XCTAssertTrue(loginMgr.isLoggedIn, @"Not logged in???");

                User *loggedInUser = (User *)loginMgr.loggedInUser;

                XCTAssertTrue([loggedInUser isKindOfClass:[User class]], @"Wrong user class!");
                XCTAssertTrue([loggedInUser.username isEqualToString:username], @"Wrong user name!");
                XCTAssertNil(loggedInUser.password, @"Password should be gone!");
                XCTAssertTrue([loggedInUser.email isEqualToString:email], @"Wrong email!");

                END_TEST
            }];
        }
        else {
            END_TEST
        }
    }];

    WAIT_FOR_TEST_END
}

- (void)testLocalOnlyUser {
    START_TEST

    User *localOnlyUser = [[User alloc] init];
    localOnlyUser.objectId = @"test_localOnly_user";
    localOnlyUser.username = @"test_localOnly_user";
    localOnlyUser.password = @"test_pWd";
    localOnlyUser.email = @"test@local.only";
    localOnlyUser.isLocalOnly = YES;

    [[FOSRESTConfig sharedInstance].databaseManager saveChanges];

    [[FOSRESTConfig sharedInstance].cacheManager flushCaches:^(BOOL isCancelled, NSError *error) {
        [[FOSRESTConfig sharedInstance].loginManager loginUser:localOnlyUser loginStyle:nil handler:^(BOOL succeeded, NSError *error) {
            FOSLoginManager *loginMgr = [FOSRESTConfig sharedInstance].loginManager;

            XCTAssertTrue(succeeded, @"Login failed: %@", error);
            XCTAssertTrue(loginMgr.isLoggedIn, @"Not logged in???");
            NSString *loggedInUid = (NSString *)loginMgr.loggedInUserId;
            XCTAssertTrue([(NSString *)localOnlyUser.uid isEqualToString:loggedInUid],
                          @"Wrong logged in uid: %@", loggedInUid);
            XCTAssertTrue([(NSString *)loginMgr.loggedInUser.uid isEqualToString:(NSString *)localOnlyUser.uid],
                         @"Wrong logged in user.uid: %@.  It should be: %@",
                         loginMgr.loggedInUser.uid, localOnlyUser.uid);

            END_TEST
        }];
    }];
    
    WAIT_FOR_TEST_END
}

#pragma mark - Private Methods

+ (User *)_testLoginUser {
    User *user = [User createLoginUser];
    user.username = @"fostest";
    user.password = @"fos!comp!rocks";
    
    return user;
}

+ (User *)_testBadLoginUser {
    User *user = [User createLoginUser];
    user.username = @"fostestbad";
    user.password = @"fos!comp!rocks";

    return user;
}

+ (User *)_testLoginUnknownUser {
    User *user = [User createLoginUser];
    user.username = @"unknown_user";
    user.password = @"fos!comp!rocks";
    user.objectId = @"****dummy_bad_test***";

    return user;
}


@end
