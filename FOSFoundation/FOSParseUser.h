//
//  FOSParseUser.h
//  FOSFoundation
//
//  Created by David Hunt on 1/3/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <FOSFoundation/FOSUser.h>


@interface FOSParseUser : FOSUser

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * emailVerified;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * sessionToken;
@property (nonatomic, retain) NSString * username;

@end
