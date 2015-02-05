//
//  FOSRetrieveLoginDataOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 5/28/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSRetrieveCMODataOperation.h>

@class FOSUser;

@interface FOSRetrieveLoginDataOperation : FOSRetrieveCMODataOperation

@property (nonatomic, strong) FOSUser *loginUser;

@end
