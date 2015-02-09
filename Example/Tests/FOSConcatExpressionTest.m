//
//  FOSConcatExpressionTest.m
//  FOSFoundation
//
//  Created by David Hunt on 3/17/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FOSFoundationTests.h"
#import "TestCreate.h"

@interface FOSConcatExpressionTest : XCTestCase

@end

@implementation FOSConcatExpressionTest

SETUP_TEARDOWN_NOLOGIN

#pragma mark - Test Class Methods

- (void)testClassMethod {
    NSString *exprString = @"__test_string";
    FOSConstantExpression *constExpr = [FOSConstantExpression constantExpressionWithValue:exprString];

    NSArray *exprs = @[ constExpr ];
    FOSConcatExpression *concatExpr = [FOSConcatExpression concatExpressionWithExpressions:exprs];

    NSArray *expectedResult = exprs;

    XCTAssertTrue([concatExpr.expressions isEqual:expectedResult], @"Bad result");
}

#pragma mark - Test Properties

- (void)testExpressions {
    NSString *exprString = @"__test_string";
    FOSConstantExpression *constExpr = [FOSConstantExpression constantExpressionWithValue:exprString];

    NSArray *exprs = @[ constExpr ];
    FOSConcatExpression *concatExpr = [[FOSConcatExpression alloc] init];
    concatExpr.expressions = exprs;

    NSArray *expectedResult = exprs;

    XCTAssertTrue([concatExpr.expressions isEqual:expectedResult], @"Bad result");
}

#pragma mark - Test Evaluation

- (void)testSingleExpression {
    NSString *exprString = @"__test_string";
    FOSConstantExpression *constExpr = [FOSConstantExpression constantExpressionWithValue:exprString];

    NSArray *exprs = @[ constExpr ];
    FOSConcatExpression *concatExpr = [FOSConcatExpression concatExpressionWithExpressions:exprs];

    NSString *expectedResult = exprString;

    NSError *error = nil;
    XCTAssertTrue([[ concatExpr evaluateWithContext:nil error:&error] isEqualToString:expectedResult],
                  @"Bad result");
    XCTAssertNil(error, @"Bad error result, expected nil");
}

- (void)testMultipleStringExpressions {
    NSString *str1 = @"__test_string1";
    FOSConstantExpression *expr1 = [FOSConstantExpression constantExpressionWithValue:str1];
    NSString *str2 = @"__test_string2";
    FOSConstantExpression *expr2 = [FOSConstantExpression constantExpressionWithValue:str2];
    NSString *str3 = @"__test_string3";
    FOSConstantExpression *expr3 = [FOSConstantExpression constantExpressionWithValue:str3];

    NSArray *exprs = @[ expr1, expr2, expr3 ];
    FOSConcatExpression *concatExpr = [FOSConcatExpression concatExpressionWithExpressions:exprs];
    NSString *expectedResult = [NSString stringWithFormat:@"%@%@%@",
                                str1, str2, str3];

    NSError *error = nil;
    XCTAssertTrue([[concatExpr evaluateWithContext:nil error:&error] isEqualToString:expectedResult],
                  @"Bad result");
    XCTAssertNil(error, @"Bad error result, expected nil");
}

- (void)testSingleNonExprExpression {
    NSNumber *exprNumber = @(42);

    NSArray *exprs = @[ exprNumber ];
    FOSConcatExpression *concatExpr = [FOSConcatExpression concatExpressionWithExpressions:exprs];

    NSError *error = nil;
    XCTAssertNil([concatExpr evaluateWithContext:nil error:&error], @"Bad result");
    XCTAssertNotNil(error, @"Bad error result, expected nil");
}

- (void)testAutoConversionExprExpression {
    NSString *str1 = @"__test_string1";
    FOSConstantExpression *expr1 = [FOSConstantExpression constantExpressionWithValue:str1];
    NSNumber *num2 = @(2);
    FOSConstantExpression *expr2 = [FOSConstantExpression constantExpressionWithValue:num2];
    NSString *str3 = @"__test_string3";
    FOSConstantExpression *expr3 = [FOSConstantExpression constantExpressionWithValue:str3];

    NSArray *exprs = @[ expr1, expr2, expr3 ];
    FOSConcatExpression *concatExpr = [FOSConcatExpression concatExpressionWithExpressions:exprs];

    NSError *error = nil;
    XCTAssertTrue([(NSString *)[concatExpr evaluateWithContext:nil error:&error] isEqualToString:@"__test_string12__test_string3"], @"Bad result");
    XCTAssertNil(error, @"Error: %@", error.description);
}

@end
