//
//  NSRelationshipDescription+FOS.m
//  FOSFoundation
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

#import <NSRelationshipDescription+FOS.h>
#import "FOSFoundation_Internal.h"

@implementation NSRelationshipDescription (FOS)

- (NSString *)jsonOrderProp {
    NSString *result = [self _bindPropertyForSelector:_cmd throwIfMissing:YES];

    return result;
}

- (FOSForcePullType)jsonRelationshipForcePull {
    FOSForcePullType result = FOSForcePullType_Never;
    NSString *propValue = [self _bindValueForSelector:_cmd throwIfMissing:NO];

    if (propValue.length > 0) {
        NSString *lcPropValue = propValue.lowercaseString;

        if ([lcPropValue isEqualToString:@"never"] ||
            [lcPropValue isEqualToString:@"no"] /* backwards comp */) {
            result = FOSForcePullType_Never;
        }
        else if ([lcPropValue isEqualToString:@"always"] ||
                 [lcPropValue isEqualToString:@"yes"] /* backwards comp */) {
            result = FOSForcePullType_Always;
        }
        else if ([lcPropValue isEqualToString:@"usecount"]) {
            result = FOSForcePullType_UseCount;
        }
        else {
            result = (FOSForcePullType)[propValue integerValue];
        }
    }

    return result;
}

#pragma mark - Private methods

- (NSString *)_bindPropertyForSelector:(SEL)aSel
                        throwIfMissing:(BOOL)throwIfMissing {
    return [self _bindSelector:aSel throwIfMissing:throwIfMissing validateResultAsProperty:YES];
}

- (NSString *)_bindValueForSelector:(SEL)aSel throwIfMissing:(BOOL)throwIfMissing {
    return [self _bindSelector:aSel throwIfMissing:throwIfMissing validateResultAsProperty:NO];
}

// NOTE: This method is an extremely *HIGH USE* method!  Its implementation is carefully
//       tuned to yield optimal performance!
- (NSString *)_bindSelector:(SEL)aSel
             throwIfMissing:(BOOL)throwIfMissing
   validateResultAsProperty:(BOOL)validateAsProperty {

    NSString *result = nil;
    NSString *selName = NSStringFromSelector(aSel);

    NSString *modelCacheKey = self.userInfo[@"__modelCacheKey"];
    if (modelCacheKey == nil) {
        modelCacheKey = [NSString stringWithFormat:@"%@::%@", self.entity.name, self.name];

        NSMutableDictionary *ui = [self.userInfo mutableCopy];
        if (ui == nil) {
            ui = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        ui[@"__modelCacheKey"] = modelCacheKey;
        self.userInfo = ui;
    }
    NSMutableDictionary *entityCache = [[FOSRESTConfig sharedInstance] modelCacheForModelKey:modelCacheKey];

    BOOL retrievedFromCache = NO;
    result = entityCache[selName];

    if (result == nil) {
        result = self.userInfo[selName];

        if (result != nil && result.length == 0) {
            result = nil;
        }
    }
    else {
        retrievedFromCache = YES;

        if ([result isKindOfClass:[NSNull class]]) {
            result = nil;
        }
    }

    if (result == nil && !retrievedFromCache) {
        Class baseClass = NSClassFromString(self.entity.managedObjectClassName);

        // If we didn't see it in the model, let's see if the
        // entity class implemented this selector
        if ([baseClass respondsToSelector:aSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            result = [baseClass performSelector:aSel];
#pragma clang diagnostic pop
        }
        else if (throwIfMissing) {
            [self _throwErrorForSelector:aSel];
        }
    }

    if (validateAsProperty && !retrievedFromCache) {
        NSArray *props = [result componentsSeparatedByString:@","];
        for (NSString *nextProp in props) {
            [self _validatePropertyExists:nextProp fromSelector:aSel];
        }
    }

    if (!retrievedFromCache) {
        if (result.length == 0) {
            result = nil;
        }

        if (result == nil) {
            entityCache[selName] = [NSNull null];
        }
        else {
            entityCache[selName] = result;
        }
    }

    return result;
}

- (void)_throwErrorForSelector:(SEL)aSel {
    NSString *selName = NSStringFromSelector(aSel);
    NSString *exceptionName = [NSString stringWithFormat:@"FOSMissing_%@", selName];

    [NSException raise:exceptionName format:@"Missing '%@' on relationship '%@' of entity '%@'.",
     selName, self.name, self.entity.name];
}

- (void)_validatePropertyExists:(NSString *)propName fromSelector:(SEL)aSel {
    if (propName.length > 0) {
        id prop = self.destinationEntity.propertiesByName[propName];
        if (prop == nil) {
            NSString *selName = NSStringFromSelector(aSel);
            NSString *exceptionName = [NSString stringWithFormat:@"FOSBadProperty"];

            NSString *msg = [NSString stringWithFormat:@"Selector '%@' on relationship '%@' of entity '%@' specified a property '%@' which does not exist on the destination entity '%@'.",
                             selName, self.name, self.entity.name, propName,
                             self.destinationEntity.name];

            NSException *e = [NSException exceptionWithName:exceptionName
                                                     reason:msg
                                                   userInfo:nil];
            @throw e;
        }
    }
}

@end
