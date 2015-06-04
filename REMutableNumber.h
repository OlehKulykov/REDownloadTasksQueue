/*
 *   Copyright (c) 2014 - 2015 Kulykov Oleh info@resident.name
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy
 *   of this software and associated documentation files (the "Software"), to deal
 *   in the Software without restriction, including without limitation the rights
 *   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *   copies of the Software, and to permit persons to whom the Software is
 *   furnished to do so, subject to the following conditions:
 *
 *   The above copyright notice and this permission notice shall be included in
 *   all copies or substantial portions of the Software.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *   THE SOFTWARE.
 */


#import <Foundation/Foundation.h>

@interface REMutableNumber : NSObject <NSCopying>

@property (nonatomic, assign, readwrite) char charValue;

@property (nonatomic, assign, readwrite) unsigned char unsignedCharValue;

@property (nonatomic, assign, readwrite) short shortValue;

@property (nonatomic, assign, readwrite) unsigned short unsignedShortValue;

@property (nonatomic, assign, readwrite) unsigned int unsignedIntValue;

@property (nonatomic, assign, readwrite) long longValue;

@property (nonatomic, assign, readwrite) unsigned long unsignedLongValue;

@property (nonatomic, assign, readwrite) long long longLongValue;

@property (nonatomic, assign, readwrite) float floatValue;

@property (nonatomic, assign, readwrite) BOOL boolValue;

@property (nonatomic, assign, readwrite) NSInteger integerValue;

@property (nonatomic, assign, readwrite) NSUInteger unsignedIntegerValue;

@property (nonatomic, assign, readwrite) unsigned long long unsignedLongLongValue;

@property (nonatomic, assign, readwrite) int intValue;

@property (nonatomic, assign, readwrite) double doubleValue;

- (id) initWithUnsignedLongLong:(unsigned long long) number;
+ (REMutableNumber *) numberWithUnsignedLongLong:(unsigned long long) number;

- (id) initWithInt:(int) number;
+ (REMutableNumber *) numberWithInt:(int) number;

- (id) initWithDouble:(double) number;
+ (REMutableNumber *) numberWithDouble:(double) number;

+ (REMutableNumber *) numberWithChar:(char) number;
- (id) initWithChar:(char) number;

+ (REMutableNumber *) numberWithUnsignedChar:(unsigned char) number;
- (id) initWithUnsignedChar:(unsigned char) number;

+ (REMutableNumber *) numberWithShort:(short) number;
- (id) initWithShort:(short) number;

+ (REMutableNumber *) numberWithUnsignedShort:(unsigned short) number;
- (id) initWithUnsignedShort:(unsigned short) number;

+ (REMutableNumber *) numberWithUnsignedInt:(unsigned int) number;
- (id) initWithUnsignedInt:(unsigned int) number;

+ (REMutableNumber *) numberWithLong:(long) number;
- (id) initWithLong:(long) number;

+ (REMutableNumber *) numberWithUnsignedLong:(unsigned long) number;
- (id) initWithUnsignedLong:(unsigned long) number;

+ (REMutableNumber *) numberWithLongLong:(long long) number;
- (id) initWithLongLong:(long long) number;

+ (REMutableNumber *) numberWithFloat:(float) number;
- (id) initWithFloat:(float) number;

+ (REMutableNumber *) numberWithBool:(BOOL) number;
- (id) initWithBool:(BOOL) number;

+ (REMutableNumber *) numberWithInteger:(NSInteger) number;
- (id) initWithInteger:(NSInteger) number;

+ (REMutableNumber *) numberWithUnsignedInteger:(NSUInteger) number;
- (id) initWithUnsignedInteger:(NSUInteger) number;

- (NSComparisonResult) compare:(NSNumber *) otherNumber;

- (BOOL) isEqualToNumber:(NSNumber *) number;

@end
