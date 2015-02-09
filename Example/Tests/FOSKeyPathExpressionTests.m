//
//  FOSBinaryExpressionTests.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"
#import "User.h"

@interface FOSKeyPathExpressionTests : XCTestCase

@end

@implementation FOSKeyPathExpressionTests

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Class Method Tests
- (void)testExpressionWithLHS_RHS {
    id<FOSExpression> lhs = [FOSConstantExpression constantExpressionWithValue:@"CMO"];
    id<FOSExpression> rhs = [FOSConstantExpression constantExpressionWithValue:@"jsonIdValue"];

    FOSKeyPathExpression *expr = [FOSKeyPathExpression keyPathExpressionWithLHS:lhs andRHS:rhs];

    XCTAssertTrue([expr.lhs isEqual:lhs], @"Bad lhs");
    XCTAssertTrue([expr.rhs isEqual:rhs], @"Bad rhs");
}

#pragma mark - Property Tests

- (void)testLHSAssignment {
    id<FOSExpression> lhs = [FOSConstantExpression constantExpressionWithValue:@"CMO"];
    FOSKeyPathExpression *expr = [[FOSKeyPathExpression alloc] init];
    expr.lhs = lhs;

    XCTAssertTrue([expr.lhs isEqual:lhs], @"Bad lhs");
}

- (void)testRHSAssignment {
    FOSKeyPathExpression *expr = [[FOSKeyPathExpression alloc] init];
    id<FOSExpression> rhs = [FOSConstantExpression constantExpressionWithValue:@"jsonIdValue"];

    expr.rhs = rhs;

    XCTAssertTrue([expr.rhs isEqual:rhs], @"Bad rhs");
}

#pragma mark - Evaluation Tests

- (void)testNilErrorValue_OnSuccess {
    TestCreate *cmo = [[TestCreate alloc] init];

    NSString *jsonIdValue = @"__test123__";
    cmo.jsonIdValue = jsonIdValue;

    id<FOSExpression> lhs = [FOSConstantExpression constantExpressionWithValue:cmo];
    id<FOSExpression> rhs = [FOSConstantExpression constantExpressionWithValue:@"jsonIdValue"];
    FOSKeyPathExpression *expr = [FOSKeyPathExpression keyPathExpressionWithLHS:lhs andRHS:rhs];

    NSString *expectedResult = jsonIdValue;

    XCTAssertTrue([[expr evaluateWithContext:nil error:nil] isEqualToString:expectedResult],
                  @"Bad result");
}

- (void)testNilErrorValue_OnFailure {
    NSString *identifier = @"--Unknown Var--";
    id<FOSExpression> lhs = [FOSVariableExpression variableExpressionWithIdentifier:identifier];
    id<FOSExpression> rhs = [FOSConstantExpression constantExpressionWithValue:@"jsonIdValue"];

    FOSKeyPathExpression *expr = [FOSKeyPathExpression keyPathExpressionWithLHS:lhs andRHS:rhs];

    XCTAssertNil([expr evaluateWithContext:nil error:nil], @"Expected nil result");
}

- (void)testNoLHS {
    FOSKeyPathExpression *expr = [[FOSKeyPathExpression alloc] init];
    id<FOSExpression> rhs = [FOSConstantExpression constantExpressionWithValue:@"jsonIdValue"];

    expr.rhs = rhs;

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:nil error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error not nil?");
}

- (void)testNoRHS {
    FOSKeyPathExpression *expr = [[FOSKeyPathExpression alloc] init];
    id<FOSExpression> lhs = [FOSConstantExpression constantExpressionWithValue:@"CMO"];

    expr.lhs = lhs;

    NSError *error = nil;
    XCTAssertFalse([expr evaluateWithContext:nil error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error not nil?");
}

- (void)testBadRHSKeyPath {
    id<FOSExpression> lhs = [FOSConstantExpression constantExpressionWithValue:@"value"];
    id<FOSExpression> rhs = [FOSConstantExpression
                             constantExpressionWithValue:@"lkasjdf; sadfoi ___&&&"];

    FOSKeyPathExpression *expr = [FOSKeyPathExpression keyPathExpressionWithLHS:lhs andRHS:rhs];

    NSError *error = nil;
    XCTAssertNil([expr evaluateWithContext:nil error:&error], @"Bad result");
    XCTAssertNotNil(error, @"error not nil?");
}

@end
