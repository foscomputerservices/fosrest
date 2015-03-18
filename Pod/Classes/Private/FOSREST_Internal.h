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

#ifdef __OBJC__
@import Foundation;
@import CoreData;
#endif

#if defined(TARGET_OS_IPHONE) || defined(TARGET_IPHONE_SIMULATOR)
@import UIKit;
#else
@import AppKit.h;
#endif

#import <FOSREST/FOSREST.h>

// Extensions
#import "NSAttributeDescription+FOS.h"
#import "NSAttributeDescription+FOS_Internal.h"
#import "NSData+Base64.h"
#import "NSDate+FOS.h"
#import "NSEntityDescription+FOS.h"
#import "NSEntityDescription+FOS_Internal.h"
#import "NSError+FOS.h"
#import "NSError+FOS_Internal.h"
#import "NSMutableDictionary+FOS.h"
#import "NSMutableString+FOS.h"
#import "NSRelationshipDescription+FOS.h"
#import "NSRelationshipDescription+FOS_Internal.h"
#import "NSString+FOS.h"
#import "FOSAdapterBindingParser+FOS_Internal.h"
#import "FOSCachedManagedObject+FOS_Internal.h"
#import "FOSRESTConfig+FOS_Internal.h"
#import "FOSRelationshipFault+FOS_Internal.h"
#import "FOSCacheManager.h"
#import "FOSDatabaseManager+FOS_Internal.h"
#import "FOSWebServiceRequest+FOS_Internal.h"
#import "FOSLoginManager_Internal.h"
#import "FOSNetworkStatusMonitor_FOS_Internal.h"

// Data model
#import "FOSDeletedObject+FOS_Internal.h"
#import "FOSManagedObject+FOS_Internal.h"
#import "FOSCachedManagedObject.h"
#import "FOSModifiedProperty.h"
#import "FOSRelationshipFault.h"
#import "FOSRetrieveRelationshipUpdatesOperation.h"
#import "FOSRetrieveCMOOperation+FOS_Internal.h"
#import "FOSCacheManager+CoreData.h"
#import "FOSMergePolicy.h"
#import "FOSParseCachedManagedObject+FOS_Internal.h"

// Logging
#import "FOSAnalytics.h"

// Search Support
#import "FOSSearchOperation+Internal.h"

// Queue Management
#import "FOSOperation.h"
#import "FOSOperationQueue+FOS_Internal.h"
#import "FOSOperationQueue.h"
#import "FOSBackgroundOperation.h"
#import "FOSBeginOperation.h"
#import "FOSSaveOperation.h"
#import "FOSSearchOperation.h"
#import "FOSSleepOperation.h"
#import "FOSOperation+FOS_Internal.h"

// Basic Pieces
#import "FOSCacheManager.h"
#import "FOSDatabaseManager.h"
#import "FOSWebService_Internal.h"

