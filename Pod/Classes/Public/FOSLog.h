//
//  FOSLog.h
//  FOSFoundation
//
//  Created by David Hunt on 5/30/14.
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

#import <Foundation/Foundation.h>

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
void FOSLogCriticalS(NSString *message);

/*!
 * @function FOSLogError
 *
 * Displays a log message at the FOSLogLevelError logging level.
 */
void FOSLogError (NSString *format, ...);
void FOSLogErrorS(NSString *message);

/*!
 * @function FOSLogWarning
 *
 * Displays a log message at the FOSLogLevelWarning logging level.
 */
void FOSLogWarning (NSString *format, ...);
void FOSLogWarningS(NSString *message);

/*!
 * @function FOSLogInfo
 *
 * Displays a log message at the FOSLogLevelInfo logging level.
 */
void FOSLogInfo (NSString *format, ...);
void FOSLogInfoS(NSString *message);

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
void FOSLogDebugS(NSString *message);

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
void FOSLogPedanticS(NSString *message);

/*!
 * @function FOSGetLogLevel
 *
 * Returns the current log level setting.
 */
FOSLogLevel FOSGetLogLevel();

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
