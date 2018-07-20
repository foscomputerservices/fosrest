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

typedef void (^FOSCacheErrorHandler)(NSError * _Nullable error);
typedef void (^FOSCacheFetchHandler)( NSManagedObjectID * _Nonnull result, NSError * _Nullable error);
typedef void (^FOSCacheSearchHandler)(NSSet * _Nullable results, NSError * _Nullable error);
typedef void (^FOSBackgroundRequest)(BOOL cancelled, NSError * _Nullable error);
typedef FOSRecoveryOption (^FOSRecoverableBackgroundRequest)(BOOL cancelled, NSError * _Nullable error);
typedef void (^FOSLoginHandler)(BOOL succeeded, NSError * _Nullable error);
typedef NSManagedObjectID * _Nullable (^FOSWebServiceWillProcessHandler)(void);

