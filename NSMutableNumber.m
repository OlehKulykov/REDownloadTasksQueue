//
//  NSMutableNumber.m
//  bumr
//
//  Created by Resident Evil on 02.12.14.
//  Copyright (c) 2014 moc. All rights reserved.
//

#import "NSMutableNumber.h"

@interface NSMutableNumber()

@property (nonatomic, strong) NSNumber * num;

@end

@implementation NSMutableNumber

- (int) intValue
{
	NSNumber * n = self.num;
	return n ? [n intValue] : 0;
}

- (void) setIntValue:(int) value
{
	self.num = [NSNumber numberWithInt:value];
}

- (unsigned long long) unsignedLongLongValue
{
	NSNumber * n = self.num;
	return n ? [n unsignedLongLongValue] : 0;
}

- (void) setUnsignedLongLongValue:(unsigned long long) value
{
	self.num = [NSNumber numberWithUnsignedLongLong:value];
}

- (NSNumber *) numberValue
{
	return self.num;
}

- (void) setNumberValue:(NSNumber *) value
{
	self.num = value;
}

- (double) doubleValue
{
	NSNumber * n = self.num;
	return n ? [n doubleValue] : 0;
}

- (void) setDoubleValue:(double) value
{
	self.num = [NSNumber numberWithDouble:value];
}

- (id) initWithUnsignedLongLong:(unsigned long long) number
{
	self = [super init];
	if (self) 
	{
		self.unsignedLongLongValue = number;
	}
	return self;
}

+ (id) numberWithUnsignedLongLong:(unsigned long long) number
{
	return [[NSMutableNumber alloc] initWithUnsignedLongLong:number];
}

- (id) initWithInt:(int) number
{
	self = [super init];
	if (self) 
	{
		self.intValue = number;
	}
	return self;
}

+ (id) numberWithInt:(int) number
{
	return [[NSMutableNumber alloc] initWithInt:number];
}

- (id) initWithDouble:(double) number
{
	self = [super init];
	if (self) 
	{
		self.doubleValue = number;
	}
	return self;	
}

+ (id) numberWithDouble:(double) number
{
	return [[NSMutableNumber alloc] initWithDouble:number];
}

- (BOOL) isEqual:(id) object
{
	if (object) 
	{
		NSNumber * n1 = [self num];
		if (n1) 
		{
			NSNumber * n2 = nil;
			
			if ([object isKindOfClass:[NSMutableNumber class]]) 
			{
				n2 = [(NSMutableNumber *)object num];
			}
			else if ([object isKindOfClass:[NSNumber class]])
			{
				n2 = (NSNumber *)object;
			}
			
			return n2 ? [n1 isEqualToNumber:n2] : NO;
		}
	}
	return [super isEqual:object];
}

- (id) copyWithZone:(NSZone *) zone
{
	NSMutableNumber * num = [[NSMutableNumber alloc] init];
	if (self.num) 
	{
		num.num = [self.num copyWithZone:zone];
	}
	return num;
}

- (NSComparisonResult) compare:(NSNumber *) otherNumber
{
	if (otherNumber) 
	{
		NSNumber * n = self.num;
		if (n) return [n compare:otherNumber];
	}
	return NSOrderedSame;
}

- (BOOL) isEqualToNumber:(NSNumber *) number
{
	if (number) 
	{
		NSNumber * n = self.num;
		if (n) return [n isEqualToNumber:number];
	}
	return NO;
}

@end
