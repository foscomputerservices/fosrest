//
//  FOSRESTConfig_FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

#import <FOSFoundation/FOSFoundation.h>

@interface FOSRESTConfig ()

+ (void)resetSharedInstance;

@property (atomic, weak) FOSOperation *pendingPushOperation;
@property (nonatomic, readonly) Class serviceRequestProcessorType;

- (NSMutableDictionary *)modelCacheForModelKey:(NSString *)modelKey;

@end
