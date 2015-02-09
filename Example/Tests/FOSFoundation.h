//
//  FOSFoundation.h
//  FOSFoundation
//
//  Created by David Hunt on 2/6/15.
//  Copyright (c) 2015 David Hunt. All rights reserved.
//

#pragma mark - Protocols
#import <FOSFoundation/FOSProcessServiceRequest.h>
#import <FOSFoundation/FOSRESTServiceAdapter.h>

#pragma mark - Log Service
#import <FOSFoundation/FOSLog.h>

#pragma mark - Extensions
#import <FOSFoundation/NSAttributeDescription+FOS.h>
#import <FOSFoundation/NSDate+FOS.h>
#import <FOSFoundation/NSEntityDescription+FOS.h>
#import <FOSFoundation/NSError+FOS.h>
#import <FOSFoundation/NSManagedObjectModel+FOS.h>
#import <FOSFoundation/NSMutableDictionary+FOS.h>
#import <FOSFoundation/NSMutableString+FOS.h>
#import <FOSFoundation/NSPropertyDescription+FOS.h>
#import <FOSFoundation/NSBundle+FOS.h>
#import <FOSFoundation/NSRelationshipDescription+FOS.h>
#import <FOSFoundation/NSString+FOS.h>

#pragma mark - Data Model
#import <FOSFoundation/FOSManagedObject.h>
#import <FOSFoundation/FOSCachedManagedObject.h>
#import <FOSFoundation/FOSParseCachedManagedObject.h>

#pragma mark - Binding Support
#import <FOSFoundation/FOSCompiledAtom.h>
#import <FOSFoundation/FOSTwoWayRecordBinding.h>
#import <FOSFoundation/FOSTwoWayPropertyBinding.h>
#import <FOSFoundation/FOSTwoWayRecordBinding.h>
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
#import <FOSFoundation/FOSEnsureNetworkConnection.h>
#import <FOSFoundation/FOSSendServerRecordOperation.h>
#import <FOSFoundation/FOSAtomicCreateServerRecordOperation.h>
#import <FOSFoundation/FOSCreateServerRecordOperation.h>
#import <FOSFoundation/FOSFlushCachesOperation.h>
#import <FOSFoundation/FOSLoginOperation.h>
#import <FOSFoundation/FOSLogoutOperation.h>
#import <FOSFoundation/FOSRetrieveLoginDataOperation.h>
#import <FOSFoundation/FOSPushCacheChangesOperation.h>
#import <FOSFoundation/FOSRefreshUserOperation.h>
#import <FOSFoundation/FOSRetrieveCMOOperation.h>
#import <FOSFoundation/FOSRetrieveToOneRelationshipOperation.h>
#import <FOSFoundation/FOSRetrieveToManyRelationshipOperation.h>
#import <FOSFoundation/FOSPullStaticTablesOperation.h>
#import <FOSFoundation/FOSSendToOneRelationshipOperation.h>
#import <FOSFoundation/FOSSendToManyRelationshipOperation.h>
#import <FOSFoundation/FOSStaticTableSearchOperation.h>
#import <FOSFoundation/FOSUpdateServerRecordOperation.h>

#import <FOSFoundation/FOSSaveOperation.h>
#import <FOSFoundation/FOSSleepOperation.h>
#import <FOSFoundation/FOSThreadSleep.h>

#pragma mark - Search Support
#import <FOSFoundation/FOSSearchOperation.h>
#import <FOSFoundation/FOSTimeFilter.h>

#pragma mark - Cache Management
#import <FOSFoundation/FOSCacheManager.h>
#import <FOSFoundation/FOSDatabaseManager.h>
#import <FOSFoundation/FOSManagedObjectContext.h>

#pragma mark - REST Adapters
#import <FOSFoundation/FOSBoundServiceAdapter.h>
#import <FOSFoundation/FOSParseServiceAdapter.h>

#pragma mark - REST Support
#import <FOSFoundation/FOSRelationshipFault.h>
#import <FOSFoundation/FOSWebServiceRequest.h>
#import <FOSFoundation/FOSParseFileService.h>
#import <FOSFoundation/FOSRESTConfig.h>
#import <FOSFoundation/FOSNetworkStatusMonitor.h>

#pragma mark - Stock Transformers
#import <FOSFoundation/FOSValueTransformer.h>
#import <FOSFoundation/FOSJSONTransformer.h>
#import <FOSFoundation/FOSURLTransformer.h>

#pragma mark - Parse.com Support
#import <FOSFoundation/FOSParseCachedManagedObject.h>
#import <FOSFoundation/FOSParseUser.h>

#pragma mark - Internal Testing Headers
#import "../Pods/Headers/Private/FOSFoundation/FOSNetworkStatusMonitor_FOS_Internal.h"
#import "../Pods/Headers/Private/FOSFoundation/FOSRESTConfig+FOS_Internal.h"
#import "../Pods/Headers/Private/FOSFoundation/FOSLoginManager_Internal.h"
#import "../Pods/Headers/Private/FOSFoundation/FOSOperation+FOS_Internal.h"
#import "../Pods/Headers/Private/FOSFoundation/FOSWebServiceRequest+FOS_Internal.h"
#import "../Pods/Headers/Private/FOSFoundation/NSError+FOS_Internal.h"
#import "../Pods/Headers/Private/FOSFoundation/FOSOperation+FOS_Internal.h"
#import "../Pods/Headers/Private/FOSFoundation/FOSPullStaticTablesOperation+FOS_Internal.h"
