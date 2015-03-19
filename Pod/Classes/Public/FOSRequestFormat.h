//
//  FOSRequestFormat.h
//  Pods
//
//  Created by David Hunt on 3/18/15.
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
 * @enum FOSRESTRequestFormat
 *
 * @constant FOSRequestFormatJSON  (Adapter binding: 'JSON') The data will be transmitted as JSON
 *           in the body of the message with a body type of 'application/json'.  This is the
 *           default for FOSRequestMethodPOST, FOSRequestMethodGET and FOSRequestMethodDELETE.
 *
 * @constant FOSRequestFormatWebform (Adapter binding: 'WEBFORM') The data will be transmitted
 *           as parameters. For FOSRequestMethodGET they are embedded in the URL; for all
 *           other request types, they are embedded in the body with a content type
 *           of 'application/x-www-form-urlencoded'.
 *
 * @constant FOSRequestFormatNoData (Adapter binding: 'NO_DATA') No object data will be
 *           transmitted in the request.
 */
typedef NS_ENUM(NSUInteger, FOSRequestFormat) {
    FOSRequestFormatJSON = 0,
    FOSRequestFormatWebform = 1,
    FOSRequestFormatNoData = 2
};
