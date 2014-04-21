//
//  FOSBeginOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import "FOSOperation.h"

@class FOSSaveOperation;

@interface FOSBeginOperation : FOSOperation

@property (nonatomic, readonly) FOSSaveOperation *saveOperation;

- (void)setGroupName:(NSString *)groupName;

@end
