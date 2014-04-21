//
//  WidgetSearchOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@interface WidgetSearchOperation : FOSSearchOperation

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) FOSJsonId uid;

@end
