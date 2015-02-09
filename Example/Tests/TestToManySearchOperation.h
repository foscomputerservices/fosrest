//
//  TestToManySearchOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/2/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import "FOSFoundation.h"

@class User;

@interface TestToManySearchOperation : FOSSearchOperation

@property (nonatomic, strong) FOSJsonId uid;
@property (nonatomic, strong) NSString *testType;

@end
