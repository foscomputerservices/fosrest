//
//  FOSBindingParser.h
//  FOSFoundation
//
//  Created by David Hunt on 3/14/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FOSAdapterBinding;

@interface FOSAdapterBindingParser : NSObject

+ (FOSAdapterBinding *)parseAdapterBinding:(NSString *)binding
                                forAdapter:(id<FOSRESTServiceAdapter>)serviceAdapter
                                     error:(NSError **)error;

#ifdef DEBUG
// TODO : This is historical only, need to replace.
- (id)parseBinding:(NSString *)str error:(NSError **)error;
#endif

@end
