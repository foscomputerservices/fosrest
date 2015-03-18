//
//  FOSREST.h
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

#pragma mark - Protocols
#import <FOSREST/FOSProcessServiceRequest.h>
#import <FOSREST/FOSRESTServiceAdapter.h>

#pragma mark - Log Service
#import <FOSREST/FOSLog.h>

#pragma mark - Extensions
#import <FOSREST/NSAttributeDescription+FOS.h>
#import <FOSREST/NSDate+FOS.h>
#import <FOSREST/NSEntityDescription+FOS.h>
#import <FOSREST/NSError+FOS.h>
#import <FOSREST/NSManagedObjectModel+FOS.h>
#import <FOSREST/NSMutableDictionary+FOS.h>
#import <FOSREST/NSMutableString+FOS.h>
#import <FOSREST/NSPropertyDescription+FOS.h>
#import <FOSREST/NSBundle+FOS.h>
#import <FOSREST/NSRelationshipDescription+FOS.h>
#import <FOSREST/NSString+FOS.h>

#pragma mark - Data Model
#import <FOSREST/FOSManagedObject.h>
#import <FOSREST/FOSCachedManagedObject.h>
#import <FOSREST/FOSParseCachedManagedObject.h>

#pragma mark - Binding Support
#import <FOSREST/FOSCompiledAtom.h>
#import <FOSREST/FOSTwoWayRecordBinding.h>
#import <FOSREST/FOSTwoWayPropertyBinding.h>
#import <FOSREST/FOSTwoWayRecordBinding.h>
#import <FOSREST/FOSExpression.h>
#import <FOSREST/FOSAdapterBinding.h>
#import <FOSREST/FOSAdapterBindingParser.h>
#import <FOSREST/FOSCMOBinding.h>
#import <FOSREST/FOSConcatExpression.h>
#import <FOSREST/FOSConstantExpression.h>
#import <FOSREST/FOSItemMatcher.h>
#import <FOSREST/FOSKeyPathExpression.h>
#import <FOSREST/FOSPropertyBinding.h>
#import <FOSREST/FOSAttributeBinding.h>
#import <FOSREST/FOSRelationshipBinding.h>
#import <FOSREST/FOSSharedBindingReference.h>
#import <FOSREST/FOSURLBinding.h>
#import <FOSREST/FOSVariableExpression.h>

#pragma mark - Logging
#import <FOSREST/FOSAnalytics.h>
#import <FOSREST/FOSParseAnalyticsManager.h>

#pragma mark - Authentication
#import <FOSREST/FOSUser.h>
#import <FOSREST/FOSLoginManager.h>

#pragma mark - Queue Management
#import <FOSREST/FOSOperation.h>
#import <FOSREST/FOSBackgroundOperation.h>
#import <FOSREST/FOSBeginOperation.h>
#import <FOSREST/FOSEnsureNetworkConnection.h>
#import <FOSREST/FOSSendServerRecordOperation.h>
#import <FOSREST/FOSAtomicCreateServerRecordOperation.h>
#import <FOSREST/FOSCreateServerRecordOperation.h>
#import <FOSREST/FOSFlushCachesOperation.h>
#import <FOSREST/FOSLoginOperation.h>
#import <FOSREST/FOSLogoutOperation.h>
#import <FOSREST/FOSRetrieveLoginDataOperation.h>
#import <FOSREST/FOSPushCacheChangesOperation.h>
#import <FOSREST/FOSRefreshUserOperation.h>
#import <FOSREST/FOSRetrieveCMOOperation.h>
#import <FOSREST/FOSRetrieveToOneRelationshipOperation.h>
#import <FOSREST/FOSRetrieveToManyRelationshipOperation.h>
#import <FOSREST/FOSPullStaticTablesOperation.h>
#import <FOSREST/FOSSendToOneRelationshipOperation.h>
#import <FOSREST/FOSSendToManyRelationshipOperation.h>
#import <FOSREST/FOSStaticTableSearchOperation.h>
#import <FOSREST/FOSUpdateServerRecordOperation.h>

#import <FOSREST/FOSSaveOperation.h>
#import <FOSREST/FOSSleepOperation.h>
#import <FOSREST/FOSThreadSleep.h>

#pragma mark - Search Support
#import <FOSREST/FOSSearchOperation.h>
#import <FOSREST/FOSTimeFilter.h>

#pragma mark - Cache Management
#import <FOSREST/FOSCacheManager.h>
#import <FOSREST/FOSDatabaseManager.h>
#import <FOSREST/FOSManagedObjectContext.h>

#pragma mark - REST Adapters
#import <FOSREST/FOSBoundServiceAdapter.h>
#import <FOSREST/FOSParseServiceAdapter.h>

#pragma mark - REST Support
#import <FOSREST/FOSRelationshipFault.h>
#import <FOSREST/FOSWebServiceRequest.h>
#import <FOSREST/FOSParseFileService.h>
#import <FOSREST/FOSRESTConfig.h>
#import <FOSREST/FOSNetworkStatusMonitor.h>

#pragma mark - Stock Transformers
#import <FOSREST/FOSValueTransformer.h>
#import <FOSREST/FOSJSONTransformer.h>
#import <FOSREST/FOSURLTransformer.h>

#pragma mark - Parse.com Support
#import <FOSREST/FOSParseCachedManagedObject.h>
#import <FOSREST/FOSParseUser.h>