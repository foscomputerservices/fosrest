//
//  FOSRESTConfigOptions.h
//  FOSRest
//
//  Created by David Hunt on 3/18/15.
//
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

/*!
 * @enum FOSRESTConfigOptions
 *
 * @constant FOSRESTConfigOptionsNone Used to turn off all other options (specified by itself)
 *
 * @constant FOSRESTConfigAutomaticallySynchronize Allows the framework to automatically push changes to the server.
 *
 * @constant FOSRESTConfigAllowFaulting Allows faults to be placed in faultable relationships, which are then faulted to their real values when the relationship is traversed.
 *
 * @constant FOSRESTConfigCaseSensitiveUserNames Forces user names to be case sensitive.  By default they are all forced to be lower case before authentication.
 *
 * @constant FOSRESTConfigDeleteDBOnLogout Deletes the database file once a user's logout process has been completed (a full synchronize of the user is done before logout completes).
 *
 * @discussion
 *
 * These configuration options turn on optional behaviors of the FOSREST service.
 */
typedef NS_OPTIONS(NSUInteger, FOSRESTConfigOptions) {
    FOSRESTConfigOptionsNone = (0),
    FOSRESTConfigAutomaticallySynchronize = (1 << 0),
    FOSRESTConfigAllowFaulting = (1 << 1),
    FOSRESTConfigCaseSensitiveUserNames = (1 << 2),
    FOSRESTConfigAllowStaticTableModifications = (1 << 3),
    FOSRESTConfigUseOfflineFiles = (1 << 4),
    FOSRESTConfigDeleteDBOnLogout = (1 << 5),
};
