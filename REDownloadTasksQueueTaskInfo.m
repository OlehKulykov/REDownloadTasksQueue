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


#import "REDownloadTasksQueueTaskInfo.h"
#import "REDownloadTasksQueue.h"
#import <Inlineobjc/NSString+Inlineobjc.h>
#import <Inlineobjc/NSArray+Inlineobjc.h>

static const NSString * const kBytesWrittedKey = @"writed";
static const NSString * const kBytesExpectedToWriteKey = @"expected";
static const NSString * const kResumeDataKey = @"resdata";
static const NSString * const kStorePathKey = @"store";
static const NSString * const kURLKey = @"url";
static const NSString * const kRequestTimeOutKey = @"timeout";
static const NSString * const kRequestCachePolicyKey = @"cachep";

@implementation REDownloadTasksQueueTaskInfo

+ (NSMutableURLRequest *) requestWithDictionary:(NSDictionary *) dict {
	if (dict) {
		NSString * urlString = [dict objectForKey:kURLKey];
		if (NSStringIsNotEmpty(urlString)) {
			NSNumber * number = [dict objectForKey:kRequestTimeOutKey];
			const NSTimeInterval timeout = number ? (NSTimeInterval)[number doubleValue] : kREDownloadTasksQueueDefaultRequestTimeout;
			
			number = [dict objectForKey:kRequestCachePolicyKey];
			const NSURLRequestCachePolicy cachePolicy = number ? (NSURLRequestCachePolicy)[number longLongValue] : kREDownloadTasksQueueDefaultRequestCachePolicy;
			
			NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] 
																		 cachePolicy:cachePolicy
																	 timeoutInterval:timeout];
			return request;
		}
	}
	return nil;
}

+ (REDownloadTasksQueueTaskInfo *) infoWithDictionary:(NSDictionary *) dict
										 forSession:(NSURLSession *) session {
	if (dict && session) {
		REDownloadTasksQueueTaskInfo * info = nil;
		NSData * resumeData = [dict objectForKey:kResumeDataKey];
		if (resumeData) {
			info = [REDownloadTasksQueueTaskInfo infoWithTask:[session downloadTaskWithResumeData:resumeData completionHandler:NULL]];
		} else {
			NSMutableURLRequest * request = [REDownloadTasksQueueTaskInfo requestWithDictionary:dict];
			if (request) {
				info = [REDownloadTasksQueueTaskInfo infoWithTask:[session downloadTaskWithRequest:request completionHandler:NULL]];
			}
		}
		if (info) {
			info.storePath = [dict objectForKey:kStorePathKey];
			id value = [dict objectForKey:kBytesWrittedKey];
			if (value) info.bytesWritted = (int64_t)[(NSNumber *)value longLongValue];
			
			value = [dict objectForKey:kBytesExpectedToWriteKey];
			if (value) info.bytesExpectedToWrite = (int64_t)[(NSNumber *)value longLongValue];
		}
		return info;
	}
	return nil;
}

+ (NSMutableDictionary *) serializeInfoToDictionary:(REDownloadTasksQueueTaskInfo *) info {
	if (!info) return nil;
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:7];
	[dict setObject:[NSNumber numberWithLongLong:info.bytesWritted] forKey:kBytesWrittedKey];
	[dict setObject:[NSNumber numberWithLongLong:info.bytesExpectedToWrite] forKey:kBytesExpectedToWriteKey];
	[dict setObject:info.storePath forKey:kStorePathKey];
	NSData * data = info.resumeData;
	if (data) {
		[dict setObject:data forKey:kResumeDataKey];
	}
	NSURLRequest * request = [info.task originalRequest];
	if (request) {
		id value = [[request URL] absoluteString];
		if (value) [dict setObject:value forKey:kURLKey];
		[dict setObject:[NSNumber numberWithDouble:(double)[request timeoutInterval]] forKey:kRequestTimeOutKey];
		[dict setObject:[NSNumber numberWithLongLong:(long long)[request cachePolicy]] forKey:kRequestCachePolicyKey];
	}
	return dict;
}

- (BOOL) cancelRunningWithCompletionHandler:(void(^)(void)) handler {
	if (!self.isStarted || self.isCanceled) return NO;
	self.isCanceled = YES;
	
	[_task cancelByProducingResumeData:^(NSData * resData){
		self.resumeData = resData;
		if (handler) handler();
	}];
	return YES;
}

- (void) cancel {
	if (!self.isStarted || self.isCanceled) return;
	self.isCanceled = YES;
	
	[_task cancel];
}

- (NSURL *) storeURL {
	return (NSStringIsNotEmpty(_storePath)) ? [NSURL fileURLWithPath:_storePath isDirectory:NO] : nil;
}

- (NSURL *) originalURL {
	NSURLRequest * request = _task ? [_task originalRequest] : nil;
	return request ? [request URL] : nil;
}

- (NSUInteger) taskIdentifier {
	return _task ? [_task taskIdentifier] : 0;
}

- (BOOL) moveToDestivationFromURL:(NSURL *) fromURL
						withError:(NSError **) error {
	if (fromURL) {
		NSString * storePath = self.storePath;
		
		BOOL isDir = YES;
		NSFileManager * manager = [NSFileManager defaultManager];
		if ([manager fileExistsAtPath:storePath isDirectory:&isDir]) {
			if (isDir) {
				if (error) {
					NSString * text = NSLocalizedString(@"Destination path exists and it's folder.", nil);
					NSError * e = [[NSError alloc] initWithDomain:@"REDownloadTasksQueue" 
															 code:-1
														 userInfo:@{NSLocalizedDescriptionKey: text}];
					*error = e;
				}
				return NO;
			} else {
				if (![manager removeItemAtPath:storePath error:error]) return NO;
			}
		}
		
		return [manager moveItemAtURL:fromURL toURL:[self storeURL] error:error];
	}
	return NO;
}

- (id) init {
	self = [super init];
	if (self) {
		_bytesWritted = -1;
		_bytesExpectedToWrite = -1;
	}
	return self;
}

+ (REDownloadTasksQueueTaskInfo *) infoWithTask:(NSURLSessionDownloadTask *) downloadTask {
	if (downloadTask && [downloadTask isKindOfClass:[NSURLSessionDownloadTask class]]) {
		REDownloadTasksQueueTaskInfo * info = [[REDownloadTasksQueueTaskInfo alloc] init];
		if (info) {
			info.task = downloadTask;
		}
		return info;
	}
	return nil;
}

@end
