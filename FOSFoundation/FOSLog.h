//
//  FOSLog.h
//  FOSFoundation
//
//  Created by David Hunt on 5/30/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "asl.h"

typedef NS_ENUM(NSUInteger, FOSLogLevel) {
    FOSLogLevelCritical,
    FOSLogLevelError,
    FOSLogLevelWarning,
    FOSLogLevelInfo,
    FOSLogLevelDebug,
    FOSLogLevelPedantic
};

/*!
 * @function FOSLogCritical
 *
 * Displays a log message at the FOSLogLevelCritical logging level.
 */
void FOSLogCritical (NSString *format, ...);

/*!
 * @function FOSLogError
 *
 * Displays a log message at the FOSLogLevelError logging level.
 */
void FOSLogError (NSString *format, ...);

/*!
 * @function FOSLogWarning
 *
 * Displays a log message at the FOSLogLevelWarning logging level.
 */
void FOSLogWarning (NSString *format, ...);

/*!
 * @function FOSLogInfo
 *
 * Displays a log message at the FOSLogLevelInfo logging level.
 */
void FOSLogInfo (NSString *format, ...);

/*!
 * @function FOSLogDebug
 *
 * Displays a log message at the FOSLogLevelDebug logging level.
 *
 * @discussion
 *
 * By default messages sent by this function will *not* be displayed
 * as FOSLogLevelDebug is lower than the default level FOSLogLevelInfo.
 *
 * To set a lower threshold, see @link FOSSetLogLevel @/link.
 */
void FOSLogDebug (NSString *format, ...);

/*!
 * @function FOSLogPedantic
 *
 * Displays a log message at the FOSLogLevelPedantic logging level.
 *
 * This log level is used to display extremely verbose debugging information
 * which may be difficult to sift through in general, but extremely useful
 * when things are going wrong.
 *
 * @discussion
 *
 * By default messages sent by this function will *not* be displayed
 * as FOSLogLevelPedantic is lower than the default level FOSLogLevelInfo.
 *
 * To set a lower threshold, see @link FOSSetLogLevel @/link.
 */
void FOSLogPedantic (NSString *format, ...);

/*!
 * @function FOSSetLogLevel
 *
 * Sets the 'lowest' level which will be output to STDERR.
 *
 * @discussion
 *
 * By default this value is set fo FOSLogLevelInfo and no
 * FOSLogDebug() messages will be displayed.  This should
 * be the 'lowest' level set for shipping applications.
 */
void FOSSetLogLevel(FOSLogLevel logLevel);
