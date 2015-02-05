//
//  WidgetSearchOperation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/28/12.
//  Copyright (c) 2012 FOS Computer Services. All rights reserved.
//

@import FOSFoundation;

@interface WidgetSearchOperation : FOSSearchOperation

@property (nonatomic, strong) NSString *widgetName;
@property (nonatomic, strong) FOSJsonId uid;

@end
