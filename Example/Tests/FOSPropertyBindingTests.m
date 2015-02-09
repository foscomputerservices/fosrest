//
//  FOSAttributeBindingTests.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"

@interface FOSAttributeBindingTests : XCTestCase

@end

@implementation FOSAttributeBindingTests

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Test Property Settings

- (void)testSimpleCMOToJSON {
    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *cmoKeyPath = @"objectId";
    id<FOSExpression> cmoKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:cmoKeyPath];
    NSPropertyDescription *cmoPropDesc = cmo.entity.propertiesByName[@"objectId"];

    NSAssert(cmoPropDesc != nil, @"Broken test!");

    NSString *originalJsonId = @"originalJsonId";
    cmo.jsonIdValue = originalJsonId;

    NSString *jsonKeyPath = @"jsonId";
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    id<FOSExpression> jsonKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:jsonKeyPath];

    FOSAttributeBinding *propBinding = [[FOSAttributeBinding alloc] init];
    propBinding.jsonKeyExpression = jsonKeyPathExpr;
    propBinding.cmoKeyPathExpression = cmoKeyPathExpr;
    propBinding.attributeMatcher = [FOSItemMatcher matcherMatchingAllItems];

    NSString *expectedResult = originalJsonId;

    NSError *error = nil;
    XCTAssertTrue([propBinding updateJSON:json fromCMO:cmo forProperty:cmoPropDesc forLifecyclePhase:FOSLifecyclePhaseCreateServerRecord error:&error],
                  @"Bad result");
    XCTAssertTrue([json[jsonKeyPath] isEqualToString:expectedResult], @"Bad result");
}

- (void)testSimpleJSONToCMO {
    TestCreate *cmo = [[TestCreate alloc] init];
    NSString *cmoKeyPath = @"objectId";
    id<FOSExpression> cmoKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:cmoKeyPath];
    NSPropertyDescription *cmoPropDesc = cmo.entity.propertiesByName[@"objectId"];

    NSAssert(cmoPropDesc != nil, @"Broken test!");

    NSString *originalJsonId = @"originalJsonId";

    NSString *jsonKeyPath = @"jsonId";
    NSDictionary *json = @{ jsonKeyPath : originalJsonId };
    id<FOSExpression> jsonKeyPathExpr = [FOSConstantExpression constantExpressionWithValue:jsonKeyPath];

    FOSAttributeBinding *propBinding = [[FOSAttributeBinding alloc] init];
    propBinding.cmoKeyPathExpression = cmoKeyPathExpr;
    propBinding.jsonKeyExpression = jsonKeyPathExpr;
    propBinding.attributeMatcher = [FOSItemMatcher matcherMatchingAllItems];

    NSString *expectedResult = originalJsonId;

    NSError *error = nil;
    XCTAssertTrue([propBinding updateCMO:cmo fromJSON:json forProperty:cmoPropDesc error:&error],
                  @"Bad result");
    XCTAssertTrue([[cmo valueForKeyPath:cmoKeyPath] isEqualToString:expectedResult], @"Bad result");
}

@end
