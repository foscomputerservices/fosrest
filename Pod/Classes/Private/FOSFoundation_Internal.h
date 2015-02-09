//
// Prefix header for all source files of the 'FOSFoundation' target in the 'FOSFoundation' project
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

#import <FOSFoundation/FOSFoundation.h>

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

