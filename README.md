## iOS Objective-C download queue based on NSURLSessionDownloadTask's. 


[![Platform](https://img.shields.io/cocoapods/p/REDownloadTasksQueue.svg?style=flat)](http://cocoapods.org/pods/REDownloadTasksQueue)
[![Version](https://img.shields.io/cocoapods/v/REDownloadTasksQueue.svg?style=flat)](http://cocoapods.org/pods/REDownloadTasksQueue)
[![License](https://img.shields.io/cocoapods/l/REDownloadTasksQueue.svg?style=flat)](http://cocoapods.org/pods/REDownloadTasksQueue)
[![OnlineDocumentation Status](https://img.shields.io/badge/online%20documentation-generated-brightgreen.svg)](http://cocoadocs.org/docsets/REDownloadTasksQueue)


### Main features:
- Using NSURLSessionDownloadTask, required iOS 7 and up.
- Using another operation queue for downloading.
- Controlling concurrent tasks for parallel downloading, can be tuned to quality of the internet connection.
- Possibility to inform about queue state via delegate, blocks and notifications. Can be selected which method to use.
- Progress calculating on downloaded data size per each task, not on simple count of tasks, for smoothly progressing.
- Queue can be serialized/deserialized for future reusing.
- Required ARC.


### Installation with CocoaPods
#### Podfile
```ruby
platform :ios, '7.0'
pod 'REDownloadTasksQueue'
```


### Create and fill queue with URL's
```objective-c
#import "REDownloadTasksQueue.h" // include single queue header file
	
self.queue = [[REDownloadTasksQueue alloc] init]; // create and store strongly queue object
for (...) // iterate URL's
{
	NSString * fromURLString = ...; // URL string for download file
	NSString * storePath = ...; // Full path for storing downloaded file data
	[_queue addURLString:fromURLString withStorePath:storePath]; // add as URL string
	[_queue addURL:[NSURL URLWithString:fromURLString] withStorePath:storePath]; // add as URL
}
[_queue start]; // start queue
```


### Track queue events via blocks 
```objective-c
[_queue setOnErrorOccurredHandler:^(REDownloadTasksQueue * queue, NSError * error, NSURL * downloadURL, NSURL * storeFilePathURL){
	NSLog(@"onErrorOccurred, error: %@, from: %@, to: %@", error, downloadURL, storeFilePathURL);
}];

[_queue setOnFinishedHandler:^(REDownloadTasksQueue * queue){
	NSLog(@"onFinished");
}];

[_queue setOnProgressHandler:^(REDownloadTasksQueue * queue, float progress){
	NSLog(@"onProgress, progress: %f %%", progress);
}];
[_queue start];
```

### Track queue events via notifications
```objective-c
#pragma mark - REDownloadTasksQueue notifications
- (void) onOnDownloadTasksQueueErrorOccurredNotification:(NSNotification *) notification
{
	NSDictionary * userInfo = [notification userInfo];
	REDownloadTasksQueue * queue = [userInfo objectForKey:kREDownloadTasksQueueQueueKey];
	id userObject = [userInfo objectForKey:kREDownloadTasksQueueUserObjectKey];
	NSError * error = [userInfo objectForKey:kREDownloadTasksQueueErrorKey];
	NSURL * downloadURL = [userInfo objectForKey:kREDownloadTasksQueueDownloadURLKey];
	NSURL * storeURL = [userInfo objectForKey:kREDownloadTasksQueueStoreURLKey];
	// Process error
}

- (void) onOnDownloadTasksQueueFinishedNotification:(NSNotification *) notification
{
	NSDictionary * userInfo = [notification userInfo];
	REDownloadTasksQueue * queue = [userInfo objectForKey:kREDownloadTasksQueueQueueKey];
	id userObject = [userInfo objectForKey:kREDownloadTasksQueueUserObjectKey];
	// Process finished situation
}

- (void) onOnDownloadTasksQueueProgressChangedNotification:(NSNotification *) notification
{
	NSDictionary * userInfo = [notification userInfo];
	REDownloadTasksQueue * queue = [userInfo objectForKey:kREDownloadTasksQueueQueueKey];
	id userObject = [userInfo objectForKey:kREDownloadTasksQueueUserObjectKey];
	NSNumber * progressNumber = [userInfo objectForKey:kREDownloadTasksQueueProgressKey];
	NSLog(@"onProgress, progress: %f %%", [progressNumber floatValue]);
	// Process progressing
}

// setup queue observing
[[NSNotificationCenter defaultCenter] addObserver:self 
										 selector:@selector(onOnDownloadTasksQueueErrorOccurredNotification:)
											 name:kREDownloadTasksQueueErrorNotification
										   object:nil /* or queue object */];

[[NSNotificationCenter defaultCenter] addObserver:self 
										 selector:@selector(onOnDownloadTasksQueueFinishedNotification:)
											 name:kREDownloadTasksQueueDidFinishedNotification
										   object:nil /* or queue object */];

[[NSNotificationCenter defaultCenter] addObserver:self 
										 selector:@selector(onOnDownloadTasksQueueProgressChangedNotification:)
											 name:kREDownloadTasksQueueProgressChangedNotification
										   object:nil /* or queue object */];

[_queue start];
```

### Track queue events via delegate
```objective-c
#pragma mark - REDownloadTasksQueueDelegate
- (void) onREDownloadTasksQueueFinished:(REDownloadTasksQueue *) queue
{
	// Process finished
}

- (void) onREDownloadTasksQueue:(REDownloadTasksQueue *) queue 
					   progress:(float) progress
{
	NSLog(@"onProgress, progress: %f %%", progress);
	// Process progressing
}

- (void) onREDownloadTasksQueue:(REDownloadTasksQueue *) queue 
						  error:(NSError *) error 
					downloadURL:(NSURL *) downloadURL 
					   storeURL:(NSURL *) storeURL
{
	// Process error
}

// setup queue delegate
[_queue setDelegate:self];
[_queue start];
```


### Serialize queue for future reusing
```objective-c
__weak SomeClassWhichHoldsQueue * weakSelf = self;
[_queue cancelAndSerializeWithRestorationID:^(NSString * restorationID){
			NSLog(@"Stored restorationID: %@", restorationID);
			weakSelf.restorationID = restorationID;
		}];
```

### Deserialize queue with restoration identifier, for example: after restart application
```objective-c
__weak SomeClassWhichHoldsQueue * weakSelf = self;
[REDownloadTasksQueue createWithRestorationID:weakSelf.restorationID 
						 andCompletionHandler:^(REDownloadTasksQueue * restoredQueue, NSError * error){
							 NSLog(@"Restored");
							 weakSelf.queue = restoredQueue;
							 [restoredQueue start];
						 }];
```


# License
---------

The MIT License (MIT)

Copyright (c) 2014 - 2016 Kulykov Oleh <info@resident.name>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

