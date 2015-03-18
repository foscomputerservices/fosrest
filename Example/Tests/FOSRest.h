//
//  FOSRest.h
//  FOSRest
//
//  Created by David Hunt on 2/6/15.
//  Copyright (c) 2015 David Hunt. All rights reserved.
//

#pragma mark - Protocols
#import <FOSRest/FOSProcessServiceRequest.h>
#import <FOSRest/FOSRESTServiceAdapter.h>

#pragma mark - Log Service
#import <FOSRest/FOSLog.h>

#pragma mark - Extensions
#import <FOSRest/NSAttributeDescription+FOS.h>
#import <FOSRest/NSDate+FOS.h>
#import <FOSRest/NSEntityDescription+FOS.h>
#import <FOSRest/NSError+FOS.h>
#import <FOSRest/NSManagedObjectModel+FOS.h>
#import <FOSRest/NSMutableDictionary+FOS.h>
#import <FOSRest/NSMutableString+FOS.h>
#import <FOSRest/NSPropertyDescription+FOS.h>
#import <FOSRest/NSBundle+FOS.h>
#import <FOSRest/NSRelationshipDescription+FOS.h>
#import <FOSRest/NSString+FOS.h>

#pragma mark - Data Model
#import <FOSRest/FOSManagedObject.h>
#import <FOSRest/FOSCachedManagedObject.h>
#import <FOSRest/FOSParseCachedManagedObject.h>

#pragma mark - Binding Support
#import <FOSRest/FOSCompiledAtom.h>
#import <FOSRest/FOSTwoWayRecordBinding.h>
#import <FOSRest/FOSTwoWayPropertyBinding.h>
#import <FOSRest/FOSTwoWayRecordBinding.h>
#import <FOSRest/FOSExpression.h>
#import <FOSRest/FOSAdapterBinding.h>
#import <FOSRest/FOSAdapterBindingParser.h>
#import <FOSRest/FOSCMOBinding.h>
#import <FOSRest/FOSConcatExpression.h>
#import <FOSRest/FOSConstantExpression.h>
#import <FOSRest/FOSItemMatcher.h>
#import <FOSRest/FOSKeyPathExpression.h>
#import <FOSRest/FOSPropertyBinding.h>
#import <FOSRest/FOSAttributeBinding.h>
#import <FOSRest/FOSRelationshipBinding.h>
#import <FOSRest/FOSSharedBindingReference.h>
#import <FOSRest/FOSURLBinding.h>
#import <FOSRest/FOSVariableExpression.h>

#pragma mark - Logging
#import <FOSRest/FOSAnalytics.h>
#import <FOSRest/FOSParseAnalyticsManager.h>

#pragma mark - Authentication
#import <FOSRest/FOSUser.h>
#import <FOSRest/FOSLoginManager.h>

#pragma mark - Queue Management
#import <FOSRest/FOSOperation.h>
#import <FOSRest/FOSBackgroundOperation.h>
#import <FOSRest/FOSBeginOperation.h>
#import <FOSRest/FOSEnsureNetworkConnection.h>
#import <FOSRest/FOSSendServerRecordOperation.h>
#import <FOSRest/FOSAtomicCreateServerRecordOperation.h>
#import <FOSRest/FOSCreateServerRecordOperation.h>
#import <FOSRest/FOSFlushCachesOperation.h>
#import <FOSRest/FOSLoginOperation.h>
#import <FOSRest/FOSLogoutOperation.h>
#import <FOSRest/FOSRetrieveLoginDataOperation.h>
#import <FOSRest/FOSPushCacheChangesOperation.h>
#import <FOSRest/FOSRefreshUserOperation.h>
#import <FOSRest/FOSRetrieveCMOOperation.h>
#import <FOSRest/FOSRetrieveToOneRelationshipOperation.h>
#import <FOSRest/FOSRetrieveToManyRelationshipOperation.h>
#import <FOSRest/FOSPullStaticTablesOperation.h>
#import <FOSRest/FOSSendToOneRelationshipOperation.h>
#import <FOSRest/FOSSendToManyRelationshipOperation.h>
#import <FOSRest/FOSStaticTableSearchOperation.h>
#import <FOSRest/FOSUpdateServerRecordOperation.h>

#import <FOSRest/FOSSaveOperation.h>
#import <FOSRest/FOSSleepOperation.h>
#import <FOSRest/FOSThreadSleep.h>

#pragma mark - Search Support
#import <FOSRest/FOSSearchOperation.h>
#import <FOSRest/FOSTimeFilter.h>

#pragma mark - Cache Management
#import <FOSRest/FOSCacheManager.h>
#import <FOSRest/FOSDatabaseManager.h>
#import <FOSRest/FOSManagedObjectContext.h>

#pragma mark - REST Adapters
#import <FOSRest/FOSBoundServiceAdapter.h>
#import <FOSRest/FOSParseServiceAdapter.h>

#pragma mark - REST Support
#import <FOSRest/FOSRelationshipFault.h>
#import <FOSRest/FOSWebServiceRequest.h>
#import <FOSRest/FOSParseFileService.h>
#import <FOSRest/FOSRESTConfig.h>
#import <FOSRest/FOSNetworkStatusMonitor.h>

#pragma mark - Stock Transformers
#import <FOSRest/FOSValueTransformer.h>
#import <FOSRest/FOSJSONTransformer.h>
#import <FOSRest/FOSURLTransformer.h>

#pragma mark - Parse.com Support
#import <FOSRest/FOSParseCachedManagedObject.h>
#import <FOSRest/FOSParseUser.h>

#pragma mark - Internal Testing Headers
//#import "../Pods/Headers/Private/FOSREST/FOSNetworkStatusMonitor_FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSRESTConfig+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSLoginManager_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSOperation+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSWebServiceRequest+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/NSError+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSOperation+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSPullStaticTablesOperation+FOS_Internal.h"
