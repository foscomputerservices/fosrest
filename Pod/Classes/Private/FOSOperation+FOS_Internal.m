//
//  FOSOperation+FOS_Internal.m
//  FOSFoundation
//
//  Created by David Hunt on 1/28/13.
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

#ifdef DEBUG
#define DEBUG_PRINT
#endif

#import "FOSOperation+FOS_Internal.h"

@implementation FOSOperation (FOS_Internal)

#pragma mark - Internal Methods

- (NSSet *)flattenedDependencies {
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.dependencies.count];

    [self _addDepsFromOperation:self toSet:result level:-1 stopAtBegin:YES];

    [result addObject:self];

    return result;
}

- (NSUInteger)calcFinishedOps {
    NSUInteger result = (self.isFinished || _mainCalled) ? 1 : 0;

    for (FOSOperation *nextOp in self.dependencies) {
        result += nextOp.finishedDependentOperations;
    }

    return result;
}

#pragma mark - Private Methods

#ifdef DEBUG_PRINT
- (void)_dumpDeps {
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.dependencies.count];

#ifdef DEBUG_PRINT
    FOSLogDebug(@"\r\nFLATTENED BEGIN ***");
#endif

    [self _addDepsFromOperation:self toSet:result level:0 stopAtBegin:YES];

#ifdef DEBUG_PRINT
    FOSLogDebug(@"\r\n*** FLATTENED END");
#endif
}
#endif

- (void)_addDepsFromOperation:(FOSOperation *)operation
                        toSet:(NSMutableSet *)set
                        level:(NSInteger)level
                   stopAtBegin:(BOOL)stopAtBegin {
    [set addObject:operation];

    NSInteger nextLevel = level >= 0 ? level + 1 : level;

    for (FOSOperation *nextOp in operation.dependencies) {

#ifdef DEBUG_PRINT
        if (level >= 0 && ![set containsObject:nextOp]) {
            NSMutableString *tabFormat = [NSMutableString stringWithCapacity:(NSUInteger)level];

            for (int i = 0; i < level; i++) {
                [tabFormat appendString:@"  "];
            }

            [tabFormat appendString:@"%i : %@ - %@ - %@ - %@"];

            FOSLogDebug(tabFormat, level, [nextOp description],
                  nextOp.isQueued ? (nextOp.isFinished ? @"FINISHED" : @"QUEUED") : @"*** NOT QUEUED ***",
                  nextOp.groupName,
                  nextOp.debugDescription);
        }
#endif

        if (![set containsObject:nextOp] &&
            !(stopAtBegin && [nextOp isKindOfClass:[FOSBeginOperation class]])) {
            [self _addDepsFromOperation:nextOp toSet:set level:nextLevel stopAtBegin:stopAtBegin];
        }
    }
}

// For testing
- (void)setError:(NSError *)error {
    _error = error;
}

@end
