//
//  fosrest.h
//  FOSREST
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
#import <fosrest/FOSJsonId.h>
#import <fosrest/FOSRESTConfigOptions.h>
#import <fosrest/FOSNetworkStatus.h>

#pragma mark - Protocols
#import <fosrest/FOSProcessServiceRequest.h>
#import <fosrest/FOSRetrieveCMODataOperationProtocol.h>
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