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


#import <Foundation/Foundation.h>

@interface REDownloadTasksQueueTaskInfo : NSObject

@property (nonatomic, strong) NSURLSessionDownloadTask * task;
@property (nonatomic, strong) NSString * storePath;
@property (nonatomic, strong) NSData * resumeData;
@property (nonatomic, assign, readwrite) int64_t bytesWritted;
@property (nonatomic, assign, readwrite) int64_t bytesExpectedToWrite;
@property (nonatomic, assign, readwrite) BOOL isStarted;
@property (nonatomic, assign, readwrite) BOOL isCanceled;

- (BOOL) cancelRunningWithCompletionHandler:(void(^)(void)) handler;

- (void) cancel;

- (NSURL *) storeURL;

- (NSURL *) originalURL;

- (NSUInteger) taskIdentifier;

- (BOOL) moveToDestivationFromURL:(NSURL *) fromURL
						withError:(NSError **) error;

+ (REDownloadTasksQueueTaskInfo *) infoWithDictionary:(NSDictionary *) dict
										   forSession:(NSURLSession *) session;

+ (REDownloadTasksQueueTaskInfo *) infoWithTask:(NSURLSessionDownloadTask *) downloadTask;

+ (NSMutableDictionary *) serializeInfoToDictionary:(REDownloadTasksQueueTaskInfo *) info;

@end

