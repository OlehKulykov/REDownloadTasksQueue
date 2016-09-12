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
#import "REDownloadTasksQueue.h"

@interface REDownloadTasksQueue () <NSURLSessionDownloadDelegate> {
@private
	NSUInteger _numberResumed;
	NSUInteger _active;
	pthread_mutex_t _mutex;
	BOOL _isFinished;
	BOOL _isCanceled;
	BOOL _isContinueOnTaskError;
}

@property (nonatomic, strong) NSMutableArray * infos;
@property (nonatomic, strong) NSURLSessionConfiguration * sessionConfiguration;
@property (nonatomic, strong) NSOperationQueue * operationQueue;
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSError * lastError;
@property (nonatomic, assign, readwrite) double total;
@property (nonatomic, assign, readwrite) double done;

- (void) lock;

- (void) unlock;

@end

