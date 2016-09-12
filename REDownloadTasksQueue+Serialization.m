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


#import "REDownloadTasksQueue+Serialization.h"
#import "REDownloadTasksQueuePrivate.h"
#import "REDownloadTasksQueueSerializer.h"
#import "REDownloadTasksQueueTaskInfo.h"
#import <NSMutableNumber/NSMutableNumber.h>
#import <Inlineobjc/NSString+Inlineobjc.h>
#import <Inlineobjc/NSArray+Inlineobjc.h>
#import <pthread.h>

@implementation REDownloadTasksQueue (Serialization)

+ (void) createWithRestorationID:(NSString *) restorationID
			andCompletionHandler:(void(^)(REDownloadTasksQueue * queue, NSError * error)) handler {
	if (!handler) return;
	if (NSStringIsEmpty(restorationID)) handler(nil, nil);
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		REDownloadTasksQueue * q = [[REDownloadTasksQueue alloc] init];
		if (!q) dispatch_async(dispatch_get_main_queue(), ^{ handler(nil, nil); });
		
		REDownloadTasksQueueSerializer * serializer = [[REDownloadTasksQueueSerializer alloc] initWithRestorationID:restorationID];
		if (!serializer) dispatch_async(dispatch_get_main_queue(), ^{ handler(nil, nil); });
		
		NSMutableArray * infos = [serializer deserializeTasksForSession:q.session];
		if (NSArrayIsNotEmpty(infos)) {
			q.infos = infos;
			q.total = serializer.total;
			q.done = serializer.done;
		}
		else q = nil;
		serializer = nil;
		[REDownloadTasksQueueSerializer removeRestorationData:restorationID];
		
		dispatch_async(dispatch_get_main_queue(), ^{ handler(q, nil); });
	});
}

- (void) serializeWithRestorationID:(void(^)(NSString * restorationID)) handler {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		REDownloadTasksQueueSerializer * serializer = [[REDownloadTasksQueueSerializer alloc] init];
		[self lock];
		if (serializer) {
			serializer.total = self.total;
			serializer.done = self.done;
			if (![serializer prepareSerialize:self.infos]) serializer = nil;
		}	
		[self unlock];
		
		if (serializer && ![serializer finishSerialization]) serializer = nil;
		
		NSString * restID = serializer ? serializer.restorationID : nil;
		serializer = nil;
		
		dispatch_async(dispatch_get_main_queue(), ^{ handler(restID); });
	});
}

- (void) cancelAndSerializeWithRestorationID:(void(^)(NSString * restorationID)) handler {
	if (!handler) return;
	
	[self cancelWithCompletionHandler:^{
		[self serializeWithRestorationID:handler];
	}];
}

+ (NSArray *) allRestorationIDs {
	return [REDownloadTasksQueueSerializer allRestorationIDs];
}

+ (void) removeRestorationIdentifier:(NSString *) restorationID {
	[REDownloadTasksQueueSerializer removeRestorationData:restorationID];
}

@end
