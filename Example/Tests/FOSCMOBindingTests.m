//
//  FOSCMOBindingTests.m
//  FOSFoundation
//
//  Created by David Hunt on 3/18/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"

@interface FOSCMOBindingTests : XCTestCase

@end

@implementation FOSCMOBindingTests

SETUP_TEARDOWN_NOLOGIN

- (void)testSimpleCMOToJSONBinding {
    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *objectId = @"__objectId";
    NSString *name = @"a name";
    cmo.objectId = objectId;
    cmo.name = name;

    FOSAttributeBinding *binding1 = [[FOSAttributeBinding alloc] init];
    binding1.jsonKeyExpression = [FOSConstantExpression constantExpressionWithValue:@"jsonId"];
    binding1.cmoKeyPathExpression = [FOSConstantExpression constantExpressionWithValue:@"objectId"];
    FOSConstantExpression *expr = [FOSConstantExpression constantExpressionWithValue:@"objectId"];
    binding1.attributeMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    FOSAttributeBinding *binding2 = [[FOSAttributeBinding alloc] init];
    binding2.jsonKeyExpression = [FOSConstantExpression constantExpressionWithValue:@"name"];
    binding2.cmoKeyPathExpression = [FOSConstantExpression constantExpressionWithValue:@"name"];
    expr = [FOSConstantExpression constantExpressionWithValue:@"name"];
    binding2.attributeMatcher = [FOSItemMatcher matcherMatchingItemExpression:expr];

    FOSCMOBinding *cmoBinding = [[FOSCMOBinding alloc] init];
    cmoBinding.entityMatcher = [FOSItemMatcher matcherMatchingAllItems];
    cmoBinding.attributeBindings = [NSSet setWithObjects:binding1, binding2, nil];

    NSDictionary *expectedResults = @{
                                      @"jsonId" : objectId,
                                      @"name" : name
                                      };

    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    NSError *error = nil;

    XCTAssertTrue([cmoBinding updateJson:json
                                 fromCMO:cmo
                       forLifecyclePhase:FOSLifecyclePhaseCreateServerRecord
                                   error:&error], @"Bad result");
    XCTAssertTrue([json isEqual:expectedResults], @"Bad results");
}

@end
