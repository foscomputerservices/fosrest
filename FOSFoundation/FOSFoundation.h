//
//  FOSFoundation.h
//  FOSFoundation
//
//  Created by David Hunt on 12/22/12.
//  Copyright (c) 2011 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Protocols
#import <FOSFoundation/FOSProcessServiceRequest.h>
#import <FOSFoundation/FOSRESTServiceAdapter.h>

#pragma mark - Extensions
#import <FOSFoundation/NSAttributeDescription+FOS.h>
#import <FOSFoundation/NSDate+FOS.h>
#import <FOSFoundation/NSEntityDescription+FOS.h>
#import <FOSFoundation/NSError+FOS.h>
#import <FOSFoundation/NSManagedObjectModel+FOS.h>
#import <FOSFoundation/NSMutableDictionary+FOS.h>
#import <FOSFoundation/NSMutableString+FOS.h>
#import <FOSFoundation/NSObject+FOS.h>
#import <FOSFoundation/NSRelationshipDescription+FOS.h>
#import <FOSFoundation/NSString+FOS.h>

#pragma mark - Data Model
#import <FOSFoundation/FOSManagedObject.h>
#import <FOSFoundation/FOSCachedManagedObject.h>
#import <FOSFoundation/FOSParseCachedManagedObject.h>

#pragma mark - Binding Support
#import <FOSFoundation/FOSTwoWayRecordBinding.h>
#import <FOSFoundation/FOSTwoWayPropertyBinding.h>
#import <FOSFoundation/FOSExpression.h>
#import <FOSFoundation/FOSAdapterBinding.h>
#import <FOSFoundation/FOSAdapterBindingParser.h>
#import <FOSFoundation/FOSCMOBinding.h>
#import <FOSFoundation/FOSConcatExpression.h>
#import <FOSFoundation/FOSConstantExpression.h>
#import <FOSFoundation/FOSItemMatcher.h>
#import <FOSFoundation/FOSKeyPathExpression.h>
#import <FOSFoundation/FOSPropertyBinding.h>
#import <FOSFoundation/FOSAttributeBinding.h>
#import <FOSFoundation/FOSRelationshipBinding.h>
#import <FOSFoundation/FOSSharedBindingReference.h>
#import <FOSFoundation/FOSURLBinding.h>
#import <FOSFoundation/FOSVariableExpression.h>

#pragma mark - Logging
#import <FOSFoundation/FOSAnalytics.h>
#import <FOSFoundation/FOSParseAnalyticsManager.h>

#pragma mark - Authentication
#import <FOSFoundation/FOSUser.h>
#import <FOSFoundation/FOSLoginManager.h>

#pragma mark - Queue Management
#import <FOSFoundation/FOSOperation.h>
#import <FOSFoundation/FOSBackgroundOperation.h>
#import <FOSFoundation/FOSBeginOperation.h>
#import <FOSFoundation/FOSSendServerRecordOperation.h>
#import <FOSFoundation/FOSAtomicCreateServerRecordOperation.h>
#import <FOSFoundation/FOSCreateServerRecordOperation.h>
#import <FOSFoundation/FOSRetrieveCMOOperation.h>
#import <FOSFoundation/FOSUpdateServerRecordOperation.h>

#import <FOSFoundation/FOSOperationQueue.h>
#import <FOSFoundation/FOSSaveOperation.h>
#import <FOSFoundation/FOSSleepOperation.h>
#import <FOSFoundation/FOSThreadSleep.h>

#pragma mark - Search Support
#import <FOSFoundation/FOSSearchOperation.h>
#import <FOSFoundation/FOSTimeFilter.h>

#pragma mark - Cache Management
#import <FOSFoundation/FOSCacheManager.h>
#import <FOSFoundation/FOSDatabaseManager.h>

#pragma mark - REST Adapters
#import <FOSFoundation/FOSBoundServiceAdapter.h>
#import <FOSFoundation/FOSParseServiceAdapter.h>

#pragma mark - REST Support
#import <FOSFoundation/FOSRelationshipFault.h>
#import <FOSFoundation/FOSWebServiceRequest.h>
#import <FOSFoundation/FOSParseFileService.h>
#import <FOSFoundation/FOSRESTConfig.h>
#import <FOSFoundation/FOSNetworkStatusMonitor.h>

#pragma mark - Parse.com Support
#import <FOSFoundation/FOSParseCachedManagedObject.h>
#import <FOSFoundation/FOSParseUser.h>
