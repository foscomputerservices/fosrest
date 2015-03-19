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
#import "FOSBindingOptions.h"
#import "FOSHandlers.h"
#import "FOSItemMatch.h"
#import "FOSJsonId.h"
#import "FOSLifecycleDirection.h"
#import "FOSLifecyclePhase.h"
#import "FOSLogLevel.h"
#import "FOSRESTConfigOptions.h"
#import "FOSNetworkStatus.h"
#import "FOSRecoveryOption.h"
#import "FOSRequestFormat.h"
#import "FOSRequestMethod.h"
#import "FOSWSRequestState.h"

#pragma mark - Protocols
#import "FOSProcessServiceRequest.h"
#import "FOSRetrieveCMODataOperationProtocol.h"
#import "FOSRESTServiceAdapter.h"

#pragma mark - Log Service
#import "FOSLog.h"

#pragma mark - Extensions
#import "NSAttributeDescription+FOS.h"
#import "NSDate+FOS.h"
#import "NSEntityDescription+FOS.h"
#import "NSError+FOS.h"
#import "NSManagedObjectModel+FOS.h"
#import "NSMutableDictionary+FOS.h"
#import "NSMutableString+FOS.h"
#import "NSPropertyDescription+FOS.h"
#import "NSBundle+FOS.h"
#import "NSRelationshipDescription+FOS.h"
#import "NSString+FOS.h"

#pragma mark - Data Model
#import "FOSManagedObject.h"
#import "FOSCachedManagedObject.h"
#import "FOSParseCachedManagedObject.h"

#pragma mark - Binding Support
#import "FOSCompiledAtom.h"
#import "FOSTwoWayRecordBinding.h"
#import "FOSTwoWayPropertyBinding.h"
#import "FOSTwoWayRecordBinding.h"
#import "FOSExpression.h"
#import "FOSAdapterBinding.h"
#import "FOSAdapterBindingParser.h"
#import "FOSCMOBinding.h"
#import "FOSConcatExpression.h"
#import "FOSConstantExpression.h"
#import "FOSItemMatcher.h"
#import "FOSKeyPathExpression.h"
#import "FOSPropertyBinding.h"
#import "FOSAttributeBinding.h"
#import "FOSRelationshipBinding.h"
#import "FOSSharedBindingReference.h"
#import "FOSURLBinding.h"
#import "FOSVariableExpression.h"

#pragma mark - Logging
#import "FOSAnalytics.h"
#import "FOSParseAnalyticsManager.h"

#pragma mark - Authentication
#import "FOSUser.h"
#import "FOSLoginManager.h"

#pragma mark - Queue Management
#import "FOSOperation.h"
#import "FOSBackgroundOperation.h"
#import "FOSBeginOperation.h"
#import "FOSEnsureNetworkConnection.h"
#import "FOSSendServerRecordOperation.h"
#import "FOSAtomicCreateServerRecordOperation.h"
#import "FOSCreateServerRecordOperation.h"
#import "FOSFlushCachesOperation.h"
#import "FOSLoginOperation.h"
#import "FOSLogoutOperation.h"
#import "FOSRetrieveLoginDataOperation.h"
#import "FOSPushCacheChangesOperation.h"
#import "FOSRefreshUserOperation.h"
#import "FOSRetrieveCMOOperation.h"
#import "FOSRetrieveToOneRelationshipOperation.h"
#import "FOSRetrieveToManyRelationshipOperation.h"
#import "FOSPullStaticTablesOperation.h"
#import "FOSSendToOneRelationshipOperation.h"
#import "FOSSendToManyRelationshipOperation.h"
#import "FOSStaticTableSearchOperation.h"
#import "FOSUpdateServerRecordOperation.h"

#import "FOSSaveOperation.h"
#import "FOSSleepOperation.h"
#import "FOSThreadSleep.h"

#pragma mark - Search Support
#import "FOSSearchOperation.h"
#import "FOSTimeFilter.h"

#pragma mark - Cache Management
#import "FOSCacheManager.h"
#import "FOSDatabaseManager.h"
#import "FOSManagedObjectContext.h"

#pragma mark - REST Adapters
#import "FOSBoundServiceAdapter.h"
#import "FOSParseServiceAdapter.h"

#pragma mark - REST Support
#import "FOSRelationshipFault.h"
#import "FOSWebServiceRequest.h"
#import "FOSParseFileService.h"
#import "FOSRESTConfig.h"
#import "FOSNetworkStatusMonitor.h"

#pragma mark - Stock Transformers
#import "FOSValueTransformer.h"
#import "FOSJSONTransformer.h"
#import "FOSURLTransformer.h"

#pragma mark - Parse.com Support
#import "FOSParseCachedManagedObject.h"
#import "FOSParseUser.h"