/*
 *   Copyright (c) 2014 - 2016 Kulykov Oleh <info@resident.name>
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


#import "REDownloadTasksQueueSerializer.h"
#import "REDownloadTasksQueueTaskInfo.h"
#import "REDownloadTasksQueuePrivate.h"
#import <CommonCrypto/CommonDigest.h>
#import <Inlineobjc/NSString+Inlineobjc.h>
#import <Inlineobjc/NSArray+Inlineobjc.h>

@interface REDownloadTasksQueueSerializer()

@property (nonatomic, strong) NSString * folderPath;
@property (nonatomic, strong) NSMutableArray * storeArray;

@end

NSString * const kDownloadTasksQueueInfosArrayKey = @"infos";
NSString * const kDownloadTasksQueueTotalKey = @"total";
NSString * const kDownloadTasksQueueDoneKey = @"done";

@implementation REDownloadTasksQueueSerializer

- (BOOL) finishSerialization {
	if (NSArrayIsNotEmpty(_storeArray)) {
		NSString * folder = [REDownloadTasksQueueSerializer storeFolder];
		if (NSStringIsNotEmpty(folder)) {
			if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
				NSError * error = nil;
				const BOOL isCreated = [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
				if (!isCreated || error) return NO;
			}
			
			NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:3];
			[dict setObject:[NSNumber numberWithDouble:self.total] forKey:kDownloadTasksQueueTotalKey];
			[dict setObject:[NSNumber numberWithDouble:self.done] forKey:kDownloadTasksQueueDoneKey];
			[dict setObject:_storeArray forKey:kDownloadTasksQueueInfosArrayKey];
			
			NSData * data = [REDownloadTasksQueueSerializer dataWithDictionary:dict];			
			NSString * storePath = [folder stringByAppendingPathComponent:_restorationID];
			return (NSStringIsNotEmpty(storePath) && data) ? [data writeToFile:storePath atomically:YES] : NO;
		}
	}
	return NO;
}

- (BOOL) prepareSerialize:(NSArray *) infosArray {
	const NSUInteger count = NSArrayCount(infosArray);
	if (count)  {
		NSMutableArray * array = [NSMutableArray arrayWithCapacity:count];
		for (REDownloadTasksQueueTaskInfo * info in infosArray) {
			NSDictionary * infoDict = [REDownloadTasksQueueTaskInfo serializeInfoToDictionary:info];
			if (infoDict) [array addObject:infoDict];
		}
		self.storeArray = array;
		return (_storeArray != nil);
	}
	return NO;
}

+ (void) removeRestorationData:(NSString *) restorationID {
	NSString * path = (NSStringIsNotEmpty(restorationID)) ? [[REDownloadTasksQueueSerializer storeFolder] stringByAppendingPathComponent:restorationID] : nil;
	if (path) {
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
}

+ (NSArray *) allRestorationIDs {
	NSString * path = [REDownloadTasksQueueSerializer storeFolder];
	if (NSStringIsNotEmpty(path)) {
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
			if (isDir) {
				NSError * error = nil;
				NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
				NSMutableArray * ids = nil;
				if (NSArrayIsNotEmpty(contents)) {
					for (NSString * p in contents) {
						NSString * last = [p lastPathComponent];
						if (NSStringIsNotEmpty(last)) {
							if (ids) [ids addObject:last];
							else ids = [NSMutableArray arrayWithObject:last];
						}
					}
				}
				return ids;
			}
		}		
	}
	return nil;
}

- (NSMutableArray *) deserializeTasksForSession:(NSURLSession *) session {
	if (NSStringIsEmpty(_folderPath) || NSStringIsEmpty(_restorationID) || !session) return nil;
	NSString * path = [_folderPath stringByAppendingPathComponent:_restorationID];
	if (NSStringIsEmpty(path)) return nil;
	
	NSError * error = nil;
	NSData * data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error];
	if (!data || error)	return nil;
	
	NSDictionary * dict = [REDownloadTasksQueueSerializer dictionaryWithData:data];
	if (!dict) return nil;
	data = nil;
	
	id value = [dict objectForKey:kDownloadTasksQueueTotalKey];
	if (value) self.total = [(NSNumber *)value doubleValue];
	else return nil;
	
	value = [dict objectForKey:kDownloadTasksQueueDoneKey];
	if (value) self.done = [(NSNumber *)value doubleValue];
	else return nil;
	
	NSArray * infosArray = [dict objectForKey:kDownloadTasksQueueInfosArrayKey];
	const NSUInteger count = NSArrayCount(infosArray);
	if (count == 0) return nil;
	
	NSMutableArray * infos = [NSMutableArray arrayWithCapacity:count];
	for (NSDictionary * infoDict in infosArray) {
		REDownloadTasksQueueTaskInfo * info = [REDownloadTasksQueueTaskInfo infoWithDictionary:infoDict forSession:session];
		if (info) [infos addObject:info];
	}
	
	return (NSArrayIsNotEmpty(infos)) ? infos : nil;
}

- (id) initWithRestorationID:(NSString *) restorationID {
	self = [super init];
	if (self) {
		NSString * path = [REDownloadTasksQueueSerializer storeFolder];
		if (NSStringIsEmpty(path)) return nil;
		
		NSString * testPath = [path stringByAppendingPathComponent:restorationID];
		BOOL isDir = YES;		
		if (NSStringIsNotEmpty(testPath) && [[NSFileManager defaultManager] fileExistsAtPath:testPath isDirectory:&isDir]) {
			if (!isDir) {
				self.restorationID = restorationID;
				self.folderPath = path;
			}
		}
	}
	return (NSStringIsNotEmpty(_restorationID) && NSStringIsNotEmpty(_folderPath)) ? self : nil;
}

- (id) init {
	self = [super init];
	if (self) {
		NSString * path = [REDownloadTasksQueueSerializer storeFolder];
		if (NSStringIsEmpty(path)) return nil;
		
		while (NSStringIsEmpty(_restorationID)) {
			NSString * idString = [REDownloadTasksQueueSerializer generateRestorationID];
			if (NSStringIsNotEmpty(idString)) {
				NSString * testPath = [path stringByAppendingPathComponent:idString];
				if (NSStringIsNotEmpty(testPath) && ![[NSFileManager defaultManager] fileExistsAtPath:testPath]) {
					self.restorationID = idString;
					self.folderPath = path;
				}		
			}
		}
	}
	return self;
}

+ (NSString *) storeFolder {
	NSArray * list = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if (NSArrayIsEmpty(list)) return nil;
	NSString * path = [list lastObject];
	return (NSStringIsNotEmpty(path)) ? [path stringByAppendingPathComponent:@"REDownloadTasksQueueSerializer"] : nil;
}

+ (NSString *) generateRestorationID {
	char part[128];
	const int partLen = sprintf(part, 
								"%llu_%f", 
								(unsigned long long)arc4random(), 
								(double)[[NSDate date] timeIntervalSince1970]);
	if (partLen > 0) {
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];
		memset(digest, 0, CC_SHA1_DIGEST_LENGTH);
		
		CC_SHA1((const void *)part, partLen, digest);
		
		const size_t buffLen = CC_SHA1_DIGEST_LENGTH * 2 + 4;
		char buff[buffLen];
		memset(buff, 0, buffLen);
		
		char * buffPtr = buff;
		for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
			sprintf(buffPtr, "%02x", digest[i]);
			buffPtr += 2;
		}
		
		return [NSString stringWithUTF8String:buff];
	}
	return nil;
}

+ (NSData *) dataWithDictionary:(NSDictionary *) dictionary {
	if (dictionary) {
		NSError * error = nil;
		NSData * res = [NSPropertyListSerialization dataWithPropertyList:dictionary 
																  format:NSPropertyListBinaryFormat_v1_0
																 options:0
																   error:&error];
		if (!error) {
			return res;
		}
	}
	return nil;
}

+ (NSDictionary *) dictionaryWithData:(NSData *) data {
	if (data) {
		NSError * error = nil; 
		NSPropertyListFormat format = (NSPropertyListFormat)0;
		id res =  [NSPropertyListSerialization propertyListWithData:data 
															options:0
															 format:&format
															  error:&error];
		if (!error && res) {
			return [res isKindOfClass:[NSDictionary class]] ? (NSDictionary *)res : nil;
		}
	}
	return nil;
}

@end
