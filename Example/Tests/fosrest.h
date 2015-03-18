//
//  fosrest.h
//  fosrest
//
//  Created by David Hunt on 2/6/15.
//  Copyright (c) 2015 David Hunt. All rights reserved.
//

#pragma mark - Protocols
#import <fosrest/FOSProcessServiceRequest.h>
#import <fosrest/FOSRESTServiceAdapter.h>

#pragma mark - Log Service
#import <fosrest/FOSLog.h>

#pragma mark - Extensions
#import <fosrest/NSAttributeDescription+FOS.h>
#import <fosrest/NSDate+FOS.h>
#import <fosrest/NSEntityDescription+FOS.h>
#import <fosrest/NSError+FOS.h>
#import <fosrest/NSManagedObjectModel+FOS.h>
#import <fosrest/NSMutableDictionary+FOS.h>
#import <fosrest/NSMutableString+FOS.h>
#import <fosrest/NSPropertyDescription+FOS.h>
#import <fosrest/NSBundle+FOS.h>
#import <fosrest/NSRelationshipDescription+FOS.h>
#import <fosrest/NSString+FOS.h>

#pragma mark - Data Model
#import <fosrest/FOSManagedObject.h>
#import <fosrest/FOSCachedManagedObject.h>
#import <fosrest/FOSParseCachedManagedObject.h>

#pragma mark - Binding Support
#import <fosrest/FOSCompiledAtom.h>
#import <fosrest/FOSTwoWayRecordBinding.h>
#import <fosrest/FOSTwoWayPropertyBinding.h>
#import <fosrest/FOSTwoWayRecordBinding.h>
#import <fosrest/FOSExpression.h>
#import <fosrest/FOSAdapterBinding.h>
#import <fosrest/FOSAdapterBindingParser.h>
#import <fosrest/FOSCMOBinding.h>
#import <fosrest/FOSConcatExpression.h>
#import <fosrest/FOSConstantExpression.h>
#import <fosrest/FOSItemMatcher.h>
#import <fosrest/FOSKeyPathExpression.h>
#import <fosrest/FOSPropertyBinding.h>
#import <fosrest/FOSAttributeBinding.h>
#import <fosrest/FOSRelationshipBinding.h>
#import <fosrest/FOSSharedBindingReference.h>
#import <fosrest/FOSURLBinding.h>
#import <fosrest/FOSVariableExpression.h>

#pragma mark - Logging
#import <fosrest/FOSAnalytics.h>
#import <fosrest/FOSParseAnalyticsManager.h>

#pragma mark - Authentication
#import <fosrest/FOSUser.h>
#import <fosrest/FOSLoginManager.h>

#pragma mark - Queue Management
#import <fosrest/FOSOperation.h>
#import <fosrest/FOSBackgroundOperation.h>
#import <fosrest/FOSBeginOperation.h>
#import <fosrest/FOSEnsureNetworkConnection.h>
#import <fosrest/FOSSendServerRecordOperation.h>
#import <fosrest/FOSAtomicCreateServerRecordOperation.h>
#import <fosrest/FOSCreateServerRecordOperation.h>
#import <fosrest/FOSFlushCachesOperation.h>
#import <fosrest/FOSLoginOperation.h>
#import <fosrest/FOSLogoutOperation.h>
#import <fosrest/FOSRetrieveLoginDataOperation.h>
#import <fosrest/FOSPushCacheChangesOperation.h>
#import <fosrest/FOSRefreshUserOperation.h>
#import <fosrest/FOSRetrieveCMOOperation.h>
#import <fosrest/FOSRetrieveToOneRelationshipOperation.h>
#import <fosrest/FOSRetrieveToManyRelationshipOperation.h>
#import <fosrest/FOSPullStaticTablesOperation.h>
#import <fosrest/FOSSendToOneRelationshipOperation.h>
#import <fosrest/FOSSendToManyRelationshipOperation.h>
#import <fosrest/FOSStaticTableSearchOperation.h>
#import <fosrest/FOSUpdateServerRecordOperation.h>

#import <fosrest/FOSSaveOperation.h>
#import <fosrest/FOSSleepOperation.h>
#import <fosrest/FOSThreadSleep.h>

#pragma mark - Search Support
#import <fosrest/FOSSearchOperation.h>
#import <fosrest/FOSTimeFilter.h>

#pragma mark - Cache Management
#import <fosrest/FOSCacheManager.h>
#import <fosrest/FOSDatabaseManager.h>
#import <fosrest/FOSManagedObjectContext.h>

#pragma mark - REST Adapters
#import <fosrest/FOSBoundServiceAdapter.h>
#import <fosrest/FOSParseServiceAdapter.h>

#pragma mark - REST Support
#import <fosrest/FOSRelationshipFault.h>
#import <fosrest/FOSWebServiceRequest.h>
#import <fosrest/FOSParseFileService.h>
#import <fosrest/FOSRESTConfig.h>
#import <fosrest/FOSNetworkStatusMonitor.h>

#pragma mark - Stock Transformers
#import <fosrest/FOSValueTransformer.h>
#import <fosrest/FOSJSONTransformer.h>
#import <fosrest/FOSURLTransformer.h>

#pragma mark - Parse.com Support
#import <fosrest/FOSParseCachedManagedObject.h>
#import <fosrest/FOSParseUser.h>

#pragma mark - Internal Testing Headers
//#import "../Pods/Headers/Private/FOSREST/FOSNetworkStatusMonitor_FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSRESTConfig+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSLoginManager_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSOperation+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSWebServiceRequest+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/NSError+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSOperation+FOS_Internal.h"
//#import "../Pods/Headers/Private/FOSREST/FOSPullStaticTablesOperation+FOS_Internal.h"
