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


#import "REDownloadTasksQueue.h"
#import "REDownloadTasksQueuePrivate.h"
#import "REDownloadTasksQueueSerializer.h"
#import "REDownloadTasksQueueTaskInfo.h"
#import <pthread.h>
#import <NSMutableNumber/NSMutableNumber.h>
#import <Inlineobjc/NSString+Inlineobjc.h>
#import <Inlineobjc/NSArray+Inlineobjc.h>

const NSTimeInterval kREDownloadTasksQueueDefaultRequestTimeout = 40;
const NSURLRequestCachePolicy kREDownloadTasksQueueDefaultRequestCachePolicy = NSURLRequestReloadIgnoringCacheData;
NSString * const _Nonnull kREDownloadTasksQueueProgressChangedNotification = @"kREDownloadTasksQueueProgressChangedNotification";
NSString * const _Nonnull kREDownloadTasksQueueDidDownloadURLProgressChangedNotification = @"kREDownloadTasksQueueDidDownloadURLProgressChangedNotification";
NSString * const _Nonnull kREDownloadTasksQueueErrorNotification = @"kREDownloadTasksQueueErrorNotification";
NSString * const _Nonnull kREDownloadTasksQueueDidFinishedNotification = @"kREDownloadTasksQueueDidFinishedNotification";
NSString * const _Nonnull kREDownloadTasksQueueProgressKey = @"progress";
NSString * const _Nonnull kREDownloadTasksQueueUserObjectKey = @"userObject";
NSString * const _Nonnull kREDownloadTasksQueueQueueKey = @"queue";
NSString * const _Nonnull kREDownloadTasksQueueErrorKey = @"error";
NSString * const _Nonnull kREDownloadTasksQueueStoreURLKey = @"storeURL";
NSString * const _Nonnull kREDownloadTasksQueueDownloadURLKey = @"downloadURL";

@implementation REDownloadTasksQueue

static bool ___initRecursiveMutex(pthread_mutex_t * mutex) {
	pthread_mutexattr_t attr;
	if (pthread_mutexattr_init(&attr) == 0) {
		bool isInit = false;
		if (pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE) == 0) {
			isInit = (pthread_mutex_init(mutex, &attr) == 0);
		}
		pthread_mutexattr_destroy(&attr);
		return isInit;
	}
	return false;
}

- (void) lock {
	pthread_mutex_lock(&_mutex);
}

- (void) unlock {
	pthread_mutex_unlock(&_mutex);
}

- (BOOL) isCanceled {
	BOOL value = NO;
	pthread_mutex_lock(&_mutex);
	value = _isCanceled;
	pthread_mutex_unlock(&_mutex);
	return value;
}

- (NSUInteger) tasksCount {
	NSUInteger value = 0;
	pthread_mutex_lock(&_mutex);
	value = _infos ? [_infos count] : 0;
	pthread_mutex_unlock(&_mutex);
	return value;
}

- (BOOL) continueOnTaskError {
	BOOL value = NO;
	pthread_mutex_lock(&_mutex);
	value = _isContinueOnTaskError;
	pthread_mutex_unlock(&_mutex);
	return value;
}

- (void) setContinueOnTaskError:(BOOL) value {
	pthread_mutex_lock(&_mutex);
	_isContinueOnTaskError = value;
	pthread_mutex_unlock(&_mutex);
}

- (BOOL) startNextTask {
	if (_isCanceled) return NO;
	BOOL isStarted = NO;
	
	pthread_mutex_lock(&_mutex);
	NSArray * infosArray = self.infos;
	if (NSArrayIsNotEmpty(infosArray) && (_active < _numberResumed))
	{		
		const NSUInteger needStart = _numberResumed - _active;
		NSUInteger started = 0;
		for (REDownloadTasksQueueTaskInfo * info in infosArray) 
		{
			if (!info.isStarted) 
			{
				NSURLSessionDownloadTask * t = [info task];
				info.isStarted = YES;
				[t resume];
				if (++started >= needStart) break;
			}
		}
		isStarted = (started > 0);
	}
	pthread_mutex_unlock(&_mutex);
	
	return isStarted;
}

- (void) reportDidDownloadURLProgressWithInfo:(REDownloadTasksQueueTaskInfo *) info {
	if (!info || _reportType == REDownloadTasksQueueReportNone) return;

	const float progress = [self downloadProgress];

	NSURL * toURL = [info storeURL];
	NSURL * fromURL = [info originalURL];
	NSMutableDictionary * userInfo = nil;
	if (_reportType & REDownloadTasksQueueReportViaNotifications) {
		userInfo = [NSMutableDictionary dictionaryWithCapacity:5];
		[userInfo setObject:self forKey:kREDownloadTasksQueueQueueKey];
		[userInfo setObject:_userObject ? _userObject : [NSNull null]
				 forKey:kREDownloadTasksQueueUserObjectKey];
		if (fromURL) [userInfo setObject:fromURL forKey:kREDownloadTasksQueueDownloadURLKey];
		if (toURL) [userInfo setObject:toURL forKey:kREDownloadTasksQueueStoreURLKey];
		[userInfo setObject:[NSNumber numberWithFloat:progress] forKey:kREDownloadTasksQueueProgressKey];
	}

	id<REDownloadTasksQueueDelegate> d = self.delegate;
	if (d && ![d respondsToSelector:@selector(onREDownloadTasksQueue:didDownloadURL:andStoredToURL:withProgress:)]) d = nil;

	dispatch_async(dispatch_get_main_queue(), ^{
		if (_onDidDownloadURLProgressHandler && (_reportType & REDownloadTasksQueueReportViaBlocks)) _onDidDownloadURLProgressHandler(self, fromURL, toURL, progress);
		if (userInfo) [[NSNotificationCenter defaultCenter] postNotificationName:kREDownloadTasksQueueDidDownloadURLProgressChangedNotification
																	  object:self
																	userInfo:userInfo];
		if (d) [d onREDownloadTasksQueue:self didDownloadURL:fromURL andStoredToURL:toURL withProgress:progress];
	});
}

- (void) reportProgress {
	if (_reportType == REDownloadTasksQueueReportNone) return;
	
	const float progress = [self downloadProgress];
	
	NSMutableDictionary * info = nil;
	if (_reportType & REDownloadTasksQueueReportViaNotifications) {
		info = [NSMutableDictionary dictionaryWithCapacity:3];
		[info setObject:self forKey:kREDownloadTasksQueueQueueKey];
		[info setObject:_userObject ? _userObject : [NSNull null]
				 forKey:kREDownloadTasksQueueUserObjectKey];
		[info setObject:[NSNumber numberWithFloat:progress] forKey:kREDownloadTasksQueueProgressKey];
	}
	
	id<REDownloadTasksQueueDelegate> d = self.delegate;
	if (d && ![d respondsToSelector:@selector(onREDownloadTasksQueue:progress:)]) d = nil;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_onProgressHandler && (_reportType & REDownloadTasksQueueReportViaBlocks)) _onProgressHandler(self, progress);
		if (info) [[NSNotificationCenter defaultCenter] postNotificationName:kREDownloadTasksQueueProgressChangedNotification 
																	  object:self
																	userInfo:info];
		if (d) [d onREDownloadTasksQueue:self progress:progress];
	});
}

- (void) reportFinished {
	if (_isFinished || _reportType == REDownloadTasksQueueReportNone) return;
	_isFinished = YES;
	
	NSMutableDictionary * info = nil;
	if (_reportType & REDownloadTasksQueueReportViaNotifications) {
		info = [NSMutableDictionary dictionaryWithCapacity:2];
		[info setObject:self forKey:kREDownloadTasksQueueQueueKey];
		[info setObject:_userObject ? _userObject : [NSNull null]
				 forKey:kREDownloadTasksQueueUserObjectKey];
	}
	
	id<REDownloadTasksQueueDelegate> d = self.delegate;
	if (d && ![d respondsToSelector:@selector(onREDownloadTasksQueueFinished:)]) d = nil;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_onFinishedHandler && (_reportType & REDownloadTasksQueueReportViaBlocks)) _onFinishedHandler(self);
		if (info) [[NSNotificationCenter defaultCenter] postNotificationName:kREDownloadTasksQueueDidFinishedNotification 
																	  object:self
																	userInfo:info];
		if (d) [d onREDownloadTasksQueueFinished:self];
	});
}

- (void) reportError:(NSError *) error
			withInfo:(REDownloadTasksQueueTaskInfo *) info {
	if (_lastError || !error || !info || _reportType == REDownloadTasksQueueReportNone) return;
	self.lastError = error;
	
	NSURL * toURL = [info storeURL];
	NSURL * fromURL = [info originalURL];
	NSMutableDictionary * userInfo = nil;
	if (_reportType & REDownloadTasksQueueReportViaNotifications) {
		userInfo = [NSMutableDictionary dictionaryWithCapacity:5];
		[userInfo setObject:self forKey:kREDownloadTasksQueueQueueKey];
		[userInfo setObject:_userObject ? _userObject : [NSNull null]
					 forKey:kREDownloadTasksQueueUserObjectKey];
		if (error) [userInfo setObject:error forKey:kREDownloadTasksQueueErrorKey];
		if (fromURL) [userInfo setObject:fromURL forKey:kREDownloadTasksQueueDownloadURLKey];
		if (toURL) [userInfo setObject:toURL forKey:kREDownloadTasksQueueStoreURLKey];
	}
	
	id<REDownloadTasksQueueDelegate> d = self.delegate;
	if (d && ![d respondsToSelector:@selector(onREDownloadTasksQueue:error:downloadURL:storeURL:)]) d = nil;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_onErrorOccurredHandler && (_reportType & REDownloadTasksQueueReportViaBlocks)) _onErrorOccurredHandler(self, error, fromURL, toURL);
		if (userInfo) [[NSNotificationCenter defaultCenter] postNotificationName:kREDownloadTasksQueueErrorNotification 
																		  object:self
																		userInfo:userInfo];
		if (d) [d onREDownloadTasksQueue:self error:error downloadURL:fromURL storeURL:toURL];
	});
}

- (BOOL) addURL:(NSURL *) url withStorePath:(NSString *) storePath {
	if (!url || [url isFileURL] || [url isFileReferenceURL]) return NO;
	if (!storePath || [storePath length] == 0) return NO;
	
	NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url 
																 cachePolicy:_cachePolicy
															 timeoutInterval:_timeoutInterval];
    return [self addURLRequest:request withStorePath:storePath];
}

- (BOOL) addURLString:(NSString *) urlString
		withStorePath:(NSString *) storePath {
	return (NSStringIsNotEmpty(urlString)) ? [self addURL:[NSURL URLWithString:urlString] withStorePath:storePath] : NO;
}

- (BOOL) addURLRequest:(NSURLRequest *) urlRequest withStorePath:(NSString *) storePath {
	NSURL * url = urlRequest ? [urlRequest URL] : nil;
    if (!url || [url isFileURL] || [url isFileReferenceURL]) return NO;
    if (NSStringIsEmpty(storePath)) return NO;
    
    REDownloadTasksQueueTaskInfo * info = [REDownloadTasksQueueTaskInfo infoWithTask:[_session downloadTaskWithRequest:urlRequest completionHandler:NULL]];
    if (info) {
		info.storePath = storePath;

        pthread_mutex_lock(&_mutex);
        if (_infos) [_infos addObject:info];
        else self.infos = [NSMutableArray arrayWithObject:info];
        _total += 1;
        pthread_mutex_unlock(&_mutex);
        
        return YES;
    }
    
    return NO;
}

- (REDownloadTasksQueueTaskInfo *) infoForTask:(NSURLSessionDownloadTask *) task {
	if (task && NSArrayIsNotEmpty(_infos)) {
		const NSUInteger tID = [task taskIdentifier];
		for (REDownloadTasksQueueTaskInfo * info in _infos)  {
			if ([info taskIdentifier] == tID) {
				return info;
			}
		}
	}
	return nil;
}

- (void) start {
	_isCanceled = NO;
	[self startNextTask];
}

- (void) cancelWithCompletionHandler:(void(^)(void)) handler {
	_isCanceled = YES;
	
	pthread_mutex_lock(&_mutex);
	NSMutableNumber * runningCount = [NSMutableNumber numberWithInt:0];
	NSArray * infosArray = self.infos;
	if (NSArrayIsNotEmpty(infosArray)) {
		int count = 0;
		for (REDownloadTasksQueueTaskInfo * info in infosArray)  {
			const BOOL isCanceledRunning = [info cancelRunningWithCompletionHandler:^{
				[self lock];
				const int count = [runningCount intValue] - 1;
				[runningCount setIntValue:count];
				[self unlock];
				if (count <= 0) {
					[runningCount setIntValue:INT_MAX];
					if (handler) dispatch_async(dispatch_get_main_queue(), ^{ handler(); });
				}
			}];
			if (isCanceledRunning) count++;
		}
		[runningCount setIntValue:count];
		if (count == 0 && handler) {
			dispatch_async(dispatch_get_main_queue(), ^{ handler(); });
		}
	} else if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{ handler(); });
	}

	if (_session) {
		[_session resetWithCompletionHandler:^{
			NSURLSession * session = self.session;
			self.session = nil;
			if (session) [session invalidateAndCancel];
		}];
	}

	pthread_mutex_unlock(&_mutex);
}

- (float) downloadProgress {
	double value = 0;
	
	pthread_mutex_lock(&_mutex);
	value = _done / _total;
	
	if (value < 0) value = 0;
	else if (value > 1) value = 1;
	pthread_mutex_unlock(&_mutex);
	
	return (float)value;
}

- (NSUInteger) numberOfResumedTasks {
	NSUInteger value = 0;
	pthread_mutex_lock(&_mutex);
	value = _numberResumed;
	pthread_mutex_unlock(&_mutex);
	return value;
}

- (void) setNumberOfResumedTasks:(NSUInteger) value {
	if (value > 0 && value <= 64)  {
		pthread_mutex_lock(&_mutex);
		_numberResumed = value;
		pthread_mutex_unlock(&_mutex);
	}
}

- (NSUInteger) numberOfMaximumConcurrentTasks {
	NSUInteger value = 0;
	pthread_mutex_lock(&_mutex);
	value = self.operationQueue.maxConcurrentOperationCount;
	pthread_mutex_unlock(&_mutex);
	return value;
}

- (void) setNumberOfMaximumConcurrentTasks:(NSUInteger) value {
	if (value > 0 && value <= 32) {
		pthread_mutex_lock(&_mutex);
		self.operationQueue.maxConcurrentOperationCount = value;
		pthread_mutex_unlock(&_mutex);
	}
}

- (BOOL) downloadTasksQueueAddInit {
	_reportType = REDownloadTasksQueueReportViaNotifications | REDownloadTasksQueueReportViaBlocks;
	_total = 0;
	_done = 0;
	_active = 0;
	_numberResumed = 4;
	_cachePolicy = kREDownloadTasksQueueDefaultRequestCachePolicy;
	_timeoutInterval = kREDownloadTasksQueueDefaultRequestTimeout;
	_isCanceled = NO;
	_isFinished = NO;
	_isContinueOnTaskError = NO;
	self.userObject = [NSNull null];
	
	self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
	if (!_sessionConfiguration) return NO;
	
	self.operationQueue = [[NSOperationQueue alloc] init];
	if (!_operationQueue) return NO;
	
	self.operationQueue.maxConcurrentOperationCount = 2;

	if (!___initRecursiveMutex(&_mutex)) return NO;

	self.session = [NSURLSession sessionWithConfiguration:_sessionConfiguration 
												 delegate:self 
											delegateQueue:_operationQueue];
	if (!_session) return NO;

	return YES;
}

- (id) init {
	self = [super init];
	if (self) {
		if (![self downloadTasksQueueAddInit]) return nil;
	}
	return self;
}

- (void) dealloc {
	[self cancelWithCompletionHandler:nil];
	pthread_mutex_destroy(&_mutex);
}

#pragma mark - session delegate
- (void) URLSession:(NSURLSession *) session 
	   downloadTask:(NSURLSessionDownloadTask *) downloadTask
didFinishDownloadingToURL:(NSURL *) location {
	
	pthread_mutex_lock(&_mutex);
	REDownloadTasksQueueTaskInfo * info = [self infoForTask:downloadTask];
	if (info)  {
		if (_active > 0) {
			_active--;
		}
		NSError * error = nil;
		if ([info moveToDestivationFromURL:location withError:&error]) {
			[_infos removeObject:info];
			
			BOOL isFinished = NO;
			if (NSArrayIsEmpty(_infos)) {
				_done = _total;
				isFinished = YES;
			} else {
				const int64_t bytesExpectedToWrite = info.bytesExpectedToWrite;
				const int64_t bytesWritted = info.bytesWritted;
				if (bytesExpectedToWrite > 0 && bytesWritted > 0) {
					const int64_t writed = bytesExpectedToWrite - bytesWritted;
					const double progress = ((double)writed) / bytesExpectedToWrite;
					_done += progress;
				} else {
					_done += 1;
				}
				[self startNextTask];
			}
			[self reportProgress];
			[self reportDidDownloadURLProgressWithInfo:info];
			if (isFinished) {
				[self cancelWithCompletionHandler:nil];
				[self reportFinished];
			}
		} else {
			[self cancelWithCompletionHandler:nil];
			[self reportError:error withInfo:info];
		}
	}
	pthread_mutex_unlock(&_mutex);
}

- (void) URLSession:(NSURLSession *) session 
	   downloadTask:(NSURLSessionDownloadTask *) downloadTask
	   didWriteData:(int64_t) bytesWritten
  totalBytesWritten:(int64_t) totalBytesWritten
totalBytesExpectedToWrite:(int64_t) totalBytesExpectedToWrite {
	
	if (bytesWritten <= 0 || totalBytesWritten <= 0 || totalBytesExpectedToWrite <= 0) return;
	
	pthread_mutex_lock(&_mutex);
	REDownloadTasksQueueTaskInfo * info = [self infoForTask:downloadTask];
	if (info) {
		if (info.bytesWritted <= 0 || info.bytesExpectedToWrite <= 0) {
			_active++;
		}
		
		info.bytesWritted = totalBytesWritten;
		info.bytesExpectedToWrite = totalBytesExpectedToWrite;
		
		const double progress = ((double)bytesWritten) / totalBytesExpectedToWrite;
		_done += progress;
		
		[self reportProgress];
	}
	pthread_mutex_unlock(&_mutex);
}

- (void) URLSession:(NSURLSession *) session 
			   task:(NSURLSessionTask *) task
didCompleteWithError:(NSError *) error {
	
	pthread_mutex_lock(&_mutex);
	if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
		REDownloadTasksQueueTaskInfo * info = [self infoForTask:(NSURLSessionDownloadTask *)task];
		if (info) {
			if (!info.isCanceled && info.isStarted) {
				if (_isContinueOnTaskError) {
					if (_active > 0) {
						_active--;
					}
					[_infos removeObject:info];
					
					BOOL isFinished = NO;
					if (NSArrayIsEmpty(_infos)) {
						_done = _total;
						isFinished = YES;
					} else {
						_done += 1;
						[self startNextTask];
					}
					[self reportProgress];
					[self reportError:error withInfo:info];
					if (isFinished) {
						[self cancelWithCompletionHandler:nil];
						[self reportFinished];
					}
				} else {
					[self cancelWithCompletionHandler:nil];
					[self reportError:error withInfo:info];
				}
			}
		}
	}
	pthread_mutex_unlock(&_mutex);
}

@end
