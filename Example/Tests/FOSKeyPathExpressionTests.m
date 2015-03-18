//
//  FOSBinaryExpressionTests.m
//  FOSREST
//
//  Created by David Hunt on 3/17/14.
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

#import <XCTest/XCTest.h>
#import "FOSRESTTests.h"
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
