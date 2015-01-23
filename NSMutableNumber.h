//
//  NSMutableNumber.h
//  bumr
//
//  Created by Resident Evil on 02.12.14.
//  Copyright (c) 2014 moc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableNumber : NSObject <NSCopying>

@property (nonatomic, assign) unsigned long long unsignedLongLongValue;

@property (nonatomic, assign) int intValue;

@property (nonatomic, assign) double doubleValue;

- (id) initWithUnsignedLongLong:(unsigned long long) number;
+ (id) numberWithUnsignedLongLong:(unsigned long long) number;

- (id) initWithInt:(int) number;
+ (id) numberWithInt:(int) number;

- (id) initWithDouble:(double) number;
+ (id) numberWithDouble:(double) number;

- (NSComparisonResult) compare:(NSNumber *) otherNumber;

- (BOOL) isEqualToNumber:(NSNumber *) number;

@end
