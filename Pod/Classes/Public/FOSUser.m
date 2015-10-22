//
//  FOSUser.m
//  FOSRest
//
//  Created by David Hunt on 12/23/12.
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

#import <FOSUser.h>
#import "FOSREST_Internal.h"

@implementation FOSUser {
    int userNum;
}

@synthesize isLoginUser = _isLoginUser;
@synthesize password = _password;

#pragma mark - Class Methods

+ (instancetype)createLoginUser {

    NSManagedObjectContext *moc = [FOSLoginManager loginUserContext];
    FOSUser *result = [[self alloc] initWithEntity:[self entityDescription]
                    insertIntoManagedObjectContext:moc];
    result->_isLoginUser = YES;

    return result;
}

static int totalUserNum = 0;
- (FOSUser *)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    if ((self = [super initWithEntity:entity insertIntoManagedObjectContext:context]) != nil) {
        userNum = totalUserNum++;
    }

    return self;
}

#pragma mark - Property Overrides

- (FOSJsonId)uid {
    return self.jsonIdValue;
}

- (NSString *)jsonUsername {
    NSString *msgFmt = @"The %@ property must be overridden by subclasses of FOSUser.";
    NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromSelector(_cmd)];

    NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];
    @throw e;
}

- (void)setJsonUsername:(NSString *)username {
    NSString *msgFmt = @"The %@ property must be overridden by subclasses of FOSUser.";
    NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromSelector(_cmd)];

    NSException *e = [NSException exceptionWithName:@"FOSREST" reason:msg userInfo:nil];
    @throw e;
}

@end
