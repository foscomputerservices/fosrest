//
//  FOSLog.m
//  FOSFoundation
//
//  Created by David Hunt on 5/30/14.
//  Copyright (c) 2014 FOS Computer Services. All rights reserved.
//

#import "FOSLog.h"

static FOSLogLevel __fosLogLevelFilter = FOSLogLevelInfo;
static void _FOSLogStderr() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asl_add_log_file(NULL, STDERR_FILENO);
    });
}

// Based on a concept from:
//   http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-FOSLogdebug-ios.html

#define __FOS_MAKE_LOG_FUNCTION(FOS_LEVEL, ASL_LEVEL, NAME) \
    void NAME (NSString *format, ...) { \
        /* Pre-filter so as to not incur overhead if no need to log */ \
        if ((FOS_LEVEL) <= __fosLogLevelFilter) { \
            _FOSLogStderr(); \
            va_list args; \
            va_start(args, format); \
            NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
            asl_log(NULL, NULL, (ASL_LEVEL), "%s", [message UTF8String]); \
            va_end(args); \
        } \
    }

//__FOS_MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, FOSLogEmergency)
//__FOS_MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, FOSLogAlert)
__FOS_MAKE_LOG_FUNCTION(FOSLogLevelCritical, ASL_LEVEL_CRIT, FOSLogCritical)
__FOS_MAKE_LOG_FUNCTION(FOSLogLevelError, ASL_LEVEL_ERR, FOSLogError)
__FOS_MAKE_LOG_FUNCTION(FOSLogLevelWarning, ASL_LEVEL_WARNING, FOSLogWarning)
//__FOS_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, FOSLogNotice)
__FOS_MAKE_LOG_FUNCTION(FOSLogLevelInfo, ASL_LEVEL_INFO, FOSLogInfo)
__FOS_MAKE_LOG_FUNCTION(FOSLogLevelDebug, ASL_LEVEL_DEBUG, FOSLogDebug)
__FOS_MAKE_LOG_FUNCTION(FOSLogLevelPedantic, ASL_LEVEL_DEBUG, FOSLogPedantic)

FOSLogLevel FOSGetLogLevel() {
    return __fosLogLevelFilter;
}

void FOSSetLogLevel(FOSLogLevel logLevel) {
    // I couldn't get asl_set_filter to work on iOS, so just made my own.
    // This way will actually be better anyway as we won't incur the overhead of creating
    // a message to send when there's no work to do anyway.
//    asl_set_filter(NULL, ASL_FILTER_MASK_UPTO(logLevel));

    __fosLogLevelFilter = logLevel;
}
