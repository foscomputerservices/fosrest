//
//  FOSConcatExpressionTest.m
//  FOSFoundation
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
