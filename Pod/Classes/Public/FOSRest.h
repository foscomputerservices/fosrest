//
//  FOSRest.h
//  FOSRest
//
//  Created by David Hunt on 2/7/15.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 FOS Services, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#pragma mark - Types
#import <FOSRest/FOSBindingOptions.h>
#import <FOSRest/FOSHandlers.h>
#import <FOSRest/FOSItemMatch.h>
#import <FOSRest/FOSJsonId.h>
#import <FOSRest/FOSLifecycleDirection.h>
#import <FOSRest/FOSLifecyclePhase.h>
#import <FOSRest/FOSLogLevel.h>
#import <FOSRest/FOSRESTConfigOptions.h>
#import <FOSRest/FOSNetworkStatus.h>
#import <FOSRest/FOSRecoveryOption.h>
#import <FOSRest/FOSRequestFormat.h>
#import <FOSRest/FOSRequestMethod.h>
#import <FOSRest/FOSWSRequestState.h>

#pragma mark - Protocols
#import <FOSRest/FOSProcessServiceRequest.h>
#import <FOSRest/FOSRetrieveCMODataOperationProtocol.h>
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