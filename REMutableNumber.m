/*
 *   Copyright (c) 2014 - 2015 Kulykov Oleh <info@resident.name>
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


#import "REMutableNumber.h"

@interface REMutableNumber()

@property (nonatomic, strong) NSNumber * num;

@end

@implementation REMutableNumber

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

- (void) setCharValue:(char) value
{
	self.num = [NSNumber numberWithChar:value];
}

- (char) charValue
{
	NSNumber * n = self.num;
	return n ? [n charValue] : 0;
}

- (void) setUnsignedCharValue:(unsigned char) value
{
	self.num = [NSNumber numberWithUnsignedChar:value];
}

- (unsigned char) unsignedCharValue
{
	NSNumber * n = self.num;
	return n ? [n unsignedCharValue] : 0;
}

- (void) setShortValue:(short) value
{
	self.num = [NSNumber numberWithShort:value];
}

- (short) shortValue
{
	NSNumber * n = self.num;
	return n ? [n shortValue] : 0;
}

- (void) setUnsignedShortValue:(unsigned short) value
{
	self.num = [NSNumber numberWithUnsignedShort:value];
}

- (unsigned short) unsignedShortValue
{
	NSNumber * n = self.num;
	return n ? [n unsignedShortValue] : 0;
}

- (void) setUnsignedIntValue:(unsigned int) value
{
	self.num = [NSNumber numberWithUnsignedInt:value];
}

- (unsigned int) unsignedIntValue
{
	NSNumber * n = self.num;
	return n ? [n unsignedIntValue] : 0;
}

- (void) setLongValue:(long) value
{
	self.num = [NSNumber numberWithLong:value];
}

- (long) longValue
{
	NSNumber * n = self.num;
	return n ? [n longValue] : 0;
}

- (void) setUnsignedLongValue:(unsigned long) value
{
	self.num = [NSNumber numberWithUnsignedLong:value];
}

- (unsigned long) unsignedLongValue
{
	NSNumber * n = self.num;
	return n ? [n unsignedLongValue] : 0;
}

- (void) setLongLongValue:(long long) value
{
	self.num = [NSNumber numberWithLongLong:value];
}

- (long long) longLongValue
{
	NSNumber * n = self.num;
	return n ? [n longLongValue] : 0;
}

- (void) setFloatValue:(float) value
{
	self.num = [NSNumber numberWithFloat:value];
}

- (float) floatValue
{
	NSNumber * n = self.num;
	return n ? [n floatValue] : 0;
}

- (void) setBoolValue:(BOOL) value
{
	self.num = [NSNumber numberWithBool:value];
}

- (BOOL) boolValue
{
	NSNumber * n = self.num;
	return n ? [n boolValue] : NO;
}

- (void) setIntegerValue:(NSInteger) value
{
	self.num = [NSNumber numberWithInteger:value];
}

- (NSInteger) integerValue
{
	NSNumber * n = self.num;
	return n ? [n integerValue] : 0;
}

- (void) setUnsignedIntegerValue:(NSUInteger) value
{
	self.num = [NSNumber numberWithUnsignedInteger:value];
}

- (NSUInteger) unsignedIntegerValue
{
	NSNumber * n = self.num;
	return n ? [n unsignedIntegerValue] : 0;
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

+ (REMutableNumber *) numberWithUnsignedLongLong:(unsigned long long) number
{
	return [[REMutableNumber alloc] initWithUnsignedLongLong:number];
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

+ (REMutableNumber *) numberWithInt:(int) number
{
	return [[REMutableNumber alloc] initWithInt:number];
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

+ (REMutableNumber *) numberWithDouble:(double) number
{
	return [[REMutableNumber alloc] initWithDouble:number];
}

+ (REMutableNumber *) numberWithChar:(char) number
{
	return [[REMutableNumber alloc] initWithChar:number];
}

- (id) initWithChar:(char) number
{
	self = [super init];
	if (self) 
	{
		self.charValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithUnsignedChar:(unsigned char) number
{
	return [[REMutableNumber alloc] initWithUnsignedChar:number];
}

- (id) initWithUnsignedChar:(unsigned char) number
{
	self = [super init];
	if (self) 
	{
		self.unsignedCharValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithShort:(short) number
{
	return [[REMutableNumber alloc] initWithShort:number];
}

- (id) initWithShort:(short) number
{
	self = [super init];
	if (self) 
	{
		self.shortValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithUnsignedShort:(unsigned short) number
{
	return [[REMutableNumber alloc] initWithUnsignedShort:number];
}

- (id) initWithUnsignedShort:(unsigned short) number
{
	self = [super init];
	if (self) 
	{
		self.unsignedShortValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithUnsignedInt:(unsigned int) number
{
	return [[REMutableNumber alloc] initWithUnsignedInt:number];
}

- (id) initWithUnsignedInt:(unsigned int) number
{
	self = [super init];
	if (self) 
	{
		self.unsignedIntValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithLong:(long) number
{
	return [[REMutableNumber alloc] initWithLong:number];
}

- (id) initWithLong:(long) number
{
	self = [super init];
	if (self) 
	{
		self.longValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithUnsignedLong:(unsigned long) number
{
	return [[REMutableNumber alloc] initWithUnsignedLong:number];
}

- (id) initWithUnsignedLong:(unsigned long) number
{
	self = [super init];
	if (self) 
	{
		self.unsignedLongValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithLongLong:(long long) number
{
	return [[REMutableNumber alloc] initWithLongLong:number];
}

- (id) initWithLongLong:(long long) number
{
	self = [super init];
	if (self) 
	{
		self.longLongValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithFloat:(float) number
{
	return [[REMutableNumber alloc] initWithFloat:number];
}

- (id) initWithFloat:(float) number
{
	self = [super init];
	if (self) 
	{
		self.floatValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithBool:(BOOL) number
{
	return [[REMutableNumber alloc] initWithBool:number];
}

- (id) initWithBool:(BOOL) number
{
	self = [super init];
	if (self) 
	{
		self.boolValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithInteger:(NSInteger) number
{
	return [[REMutableNumber alloc] initWithInteger:number];
}

- (id) initWithInteger:(NSInteger) number
{
	self = [super init];
	if (self) 
	{
		self.integerValue = number;
	}
	return self;
}

+ (REMutableNumber *) numberWithUnsignedInteger:(NSUInteger) number
{
	return [[REMutableNumber alloc] initWithUnsignedInteger:number];
}

- (id) initWithUnsignedInteger:(NSUInteger) number
{
	self = [super init];
	if (self) 
	{
		self.unsignedIntegerValue = number;
	}
	return self;
}

- (BOOL) isEqual:(id) object
{
	if (object) 
	{
		NSNumber * n1 = [self num];
		if (n1) 
		{
			NSNumber * n2 = nil;
			
			if ([object isKindOfClass:[REMutableNumber class]]) 
			{
				n2 = [(REMutableNumber *)object num];
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
	REMutableNumber * num = [[REMutableNumber alloc] init];
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
