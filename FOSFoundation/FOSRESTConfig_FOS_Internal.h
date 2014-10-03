//
//  FOSRESTConfig_FOS_Internal.h
//  FOSFoundation
//
//  Created by David Hunt on 1/5/13.
//  Copyright (c) 2013 FOS Computer Services. All rights reserved.
//

@interface FOSRESTConfig ()

+ (void)resetSharedInstance;

+ (void)configWithApplicationVersion:(NSString *)appVersion options:(FOSRESTConfigOptions)options userSubType:(Class)userSubType  restServiceAdapter:(id <FOSRESTServiceAdapter>)restServiceAdapter;

@property (atomic, strong) FOSOperation *pendingPushOperation;
@property (nonatomic, readonly) Class serviceRequestProcessorType;

- (NSMutableDictionary *)modelCacheForModelKey:(NSString *)modelKey;

@end
