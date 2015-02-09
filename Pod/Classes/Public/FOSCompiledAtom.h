//
//  FOSCompiledAtom.h
//  FOSFoundation
//
//  Created by David Hunt on 5/30/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FOSRESTServiceAdapter;

@protocol FOSCompiledAtomInfo <NSObject>

@property (nonatomic, assign) NSInteger atomStartLineNum;
@property (nonatomic, assign) NSInteger atomStartColNum;
@property (nonatomic, strong) NSString *atomName;
@property (nonatomic, readonly) NSString *atomDescription;
@property (nonatomic, weak) id<FOSRESTServiceAdapter> serviceAdapter;

@end

@interface FOSCompiledAtom : NSObject<FOSCompiledAtomInfo>

@end
