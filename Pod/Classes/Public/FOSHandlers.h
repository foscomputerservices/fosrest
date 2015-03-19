//
//  FOSHandlers.h
//  Pods
//
//  Created by David Hunt on 3/18/15.
//
//

@import Foundation;
@import CoreData;
#import "FOSRecoveryOption.h"

typedef void (^FOSCacheErrorHandler)(NSError *error);
typedef void (^FOSCacheFetchHandler)(NSManagedObjectID *result, NSError *error);
typedef void (^FOSCacheSearchHandler)(NSSet *results, NSError *error);
typedef void (^FOSBackgroundRequest)(BOOL cancelled, NSError *error);
typedef FOSRecoveryOption (^FOSRecoverableBackgroundRequest)(BOOL cancelled, NSError *error);
typedef void (^FOSLoginHandler)(BOOL succeeded, NSError *error);
typedef NSManagedObjectID *(^FOSWebServiceWillProcessHandler)();

