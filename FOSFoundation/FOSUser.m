//
//  FOSUser.m
//  FOSFoundation
//
//  Created by David Hunt on 12/23/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSUser.h"
#import "FOSFoundation_Internal.h"

@implementation FOSUser

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

#pragma mark - Property Overrides

- (FOSJsonId)uid {
    return self.jsonIdValue;
}

- (NSString *)jsonUsername {
    NSString *msgFmt = @"The %@ property must be overridden by subclasses of FOSUser.";
    NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromSelector(_cmd)];

    NSException *e = [NSException exceptionWithName:@"FOSFoundation" reason:msg userInfo:nil];
    @throw e;
}

- (void)setJsonUsername:(NSString *)username {
    NSString *msgFmt = @"The %@ property must be overridden by subclasses of FOSUser.";
    NSString *msg = [NSString stringWithFormat:msgFmt, NSStringFromSelector(_cmd)];

    NSException *e = [NSException exceptionWithName:@"FOSFoundation" reason:msg userInfo:nil];
    @throw e;
}

@end
