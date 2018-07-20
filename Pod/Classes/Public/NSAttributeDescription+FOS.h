//
//  NSAttributeDescription+FOS.h
//  FOSRest
//
//  Created by David Hunt on 12/22/12.
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

@import Foundation;
@import CoreData;

/*!
 * @category NSAttributeDescription (FOS)
 *
 * This category provides access to key-value pairs
 * provided in the NSAttributeDescription userInfo
 * NSDictionary.  The names of the properties in this
 * interface correspond directly to key names that
 * are to be provided in the userInfo dictionary.
 *
 * Normally these values are set in the database
 * model modified using Xcode's database modeling
 * tools.
 */
@interface NSAttributeDescription (FOS)

/*!
 * @property jsonLogInProp
 *
 * The name of a key in the JSON that identifies the
 * value to be used for the corresponding attribute
 * in the object model for a server login request.
 *
 * @return Returns nil if there is no corresponding key in
 * the data model.
 */
@property (nonatomic, readonly) NSString *jsonLogInProp;

/*!
 * @property jsonLogOutProp
 *
 * The name of a key in the JSON that identifies the
 * value to be used for the corresponding attribute
 * in the object model for a server log out request.
 *
 * @return Returns nil if there is no corresponding key in
 * the data model.
 */
@property (nonatomic, readonly) NSString *jsonLogOutProp;

@end
