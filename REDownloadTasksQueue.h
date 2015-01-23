/*
 *   Copyright (c) 2014 - 2015 Kulykov Oleh <nonamedemail@gmail.com>
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


#ifndef RE_EXTERN

#if defined(UIKIT_EXTERN)
#  define RE_EXTERN UIKIT_EXTERN 
#elif defined(FOUNDATION_EXTERN)
#  define RE_EXTERN FOUNDATION_EXTERN
#else
#  ifdef __cplusplus
#    define RE_EXTERN extern "C" 
#  else
#    define RE_EXTERN extern 
#  endif
#endif

#if defined(NS_INLINE)
#  define RE_INLINE NS_INLINE 
#elif defined(CG_INLINE)
#  define RE_INLINE CG_INLINE 
#else
#  define RE_INLINE 
#endif

#endif


#if !defined(_DEBUG_LOG) && !defined(_DEBUG_LOGA)
#  if defined(DEBUG) || defined(_DEBUG)
#    define _DEBUG_LOG(s) NSLog(s); 
#    define _DEBUG_LOGA(s, ...) NSLog(s, ##__VA_ARGS__); 
#  else
#    define _DEBUG_LOG(s)  
#    define _DEBUG_LOGA(s, ...)  
#  endif
#endif


/**
 @brief Reporting type of the queue.
 */
typedef NS_ENUM(NSUInteger, REDownloadTasksQueueReportType) 
{
	/**
	 @brief Silent mode. In this case notifications and callback will be ignored.
	 */
	REDownloadTasksQueueReportNone = 0,
	
	
	/**
	 @brief Reporting using 'NSNotificationCenter defaultCenter'.
	 @detailed In this case use notifications for listening queue.
	 */
	REDownloadTasksQueueReportViaNotifications = 1 << 0,
	
	
	/**
	 @brief Reporting using blocks, of cource if blocks provided.
	 */
	REDownloadTasksQueueReportViaBlocks = 1 << 1
};


/**
 @brief Default timeout of the download requests.
 @detailed Value is 40 seconds.
 */
RE_EXTERN const NSTimeInterval kREDownloadTasksQueueDefaultRequestTimeout;


/**
 @brief Default cache policy used for the download requests.
 @detailed Value is NSURLRequestReloadIgnoringCacheData.
 */
RE_EXTERN const NSURLRequestCachePolicy kREDownloadTasksQueueDefaultRequestCachePolicy;


/**
 @brief Arrived when download progress changed.
 User info dictionary is: @{@"queue" : REDownloadTasksQueue, @"userObject" : UserObject, @"progress" : NSNumberValue}.
 @warning Key = kREDownloadTasksQueueQueueKey; Value = REDownloadTasksQueue object.
 @warning Key = kREDownloadTasksQueueUserObjectKey;  Value = user object or [NSNull null]
 @warning Key = kREDownloadTasksQueueProgressKey;  Value = 'NSNumber' object.
 */
RE_EXTERN NSString * const kREDownloadTasksQueueProgressChangedNotification;


/**
 @brief Arrived on error.
 User info dictionary is: @{@"queue" : REDownloadTasksQueue, @"userObject" : UserObject, @"error" : NSError object, @"storeURL" : NSURL object}. 
 @warning Key = kREDownloadTasksQueueQueueKey; Value = DownloadTasksQueue object.
 @warning Key = kREDownloadTasksQueueUserObjectKey;  Value = user object or [NSNull null]
 @warning Key = kREDownloadTasksQueueErrorKey; Value = 'NSError' object.
 @warning Key = kREDownloadTasksQueueStoreURLKey; Value = 'NSURL' object.
 */
RE_EXTERN NSString * const kREDownloadTasksQueueErrorNotification;


/**
 @brief Arrived on all tasks done.
 User info dictionary is: @{@"queue" : REDownloadTasksQueue, @"userObject" : UserObject }. 
 @warning Key = kREDownloadTasksQueueQueueKey; Value = DownloadTasksQueue object.
 @warning Key = kREDownloadTasksQueueUserObjectKey;  Value = user object or [NSNull null]
 */
RE_EXTERN NSString * const kREDownloadTasksQueueDidFinishedNotification;


/**
 @brief Key used for download queue.
 @detailed Value is @"queue".
 */
RE_EXTERN NSString * const kREDownloadTasksQueueQueueKey;


/**
 @brief Key used for download progress.
 @detailed Value is @"progress".
 */
RE_EXTERN NSString * const kREDownloadTasksQueueProgressKey;


/**
 @brief Key used for queue user object.
 @detailed Value is @"userObject".
 */
RE_EXTERN NSString * const kREDownloadTasksQueueUserObjectKey;


/**
 @brief Key used for queue error.
 @detailed Value is @"error".
 */
RE_EXTERN NSString * const kREDownloadTasksQueueErrorKey;


/**
 @brief Key used for store file URL object.
 @detailed Value is @"storeURL".
 */
RE_EXTERN NSString * const kREDownloadTasksQueueStoreURLKey;


/**
 @brief Class of the queue based on NSURLSessionDownloadTask tasks.
 */
@interface REDownloadTasksQueue : NSObject

/**
 @brief Type of reporting using binary OR flags. Use REDownloadTasksQueueReportType values.
 @detailed Default is both methods for reporting.
 */
@property (nonatomic, assign, readwrite) NSUInteger reportType;


/**
 @brief Cache policy of the requests. Used when some url is adding to queue.
 @detailed Default value is kREDownloadTasksQueueDefaultRequestCachePolicy.
 */
@property (nonatomic, assign, readwrite) NSURLRequestCachePolicy cachePolicy;


/**
 @brief Timeout interval of the requests. Used when some url is adding to queue.
 @detailed Default value is 'kREDownloadTasksQueueDefaultRequestTimeout'.
 */
@property (nonatomic, assign, readwrite) NSTimeInterval timeoutInterval;


/**
 @brief Downloading progress of the queue. Calculates on downloaded data size.
 @detailed Default is 0. Value between 0 and 1, [0, 1].
 */
@property (nonatomic, assign, readonly) float downloadProgress;


/**
 @brief User defined object for identifing queue. Posted with notifications.
 @detailed Default is '[NSNull null]'.
 */
@property (nonatomic, strong) id userObject;


/**
 @brief Number of tasks in the queue. 
 @detailed During downloading this value is decrementing, when some task successfully finished.
 */
@property (nonatomic, assign, readonly) NSUInteger tasksCount;


/**
 @brief Block handler for reporting queue download progress. Can be NULL.
 @detailed Arrived on 'main queue'.
 @warning Used ONLY if 'REDownloadTasksQueueReportViaBlocks' type present in 'reportType' property.
 */
@property (nonatomic, copy) void(^onProgressHandler)(REDownloadTasksQueue * queue, float progress);


/**
 @brief Block handler for reporting queue finished work(all tasks successfully finished).
 @detailed Arrived on 'main queue'.
 @warning Used ONLY if 'REDownloadTasksQueueReportViaBlocks' type present in 'reportType' property.
 */
@property (nonatomic, copy) void(^onFinishedHandler)(REDownloadTasksQueue * queue);


/**
 @brief Block handler for reporting queue error. Before this, queue is cancelled.
 @detailed Arrived on 'main queue'.
 @warning Used ONLY if 'REDownloadTasksQueueReportViaBlocks' type present in 'reportType' property.
 */
@property (nonatomic, copy) void(^onErrorOccurredHandler)(REDownloadTasksQueue * queue, NSError * error, NSURL * storeFilePathURL);


/**
 @brief Number of the tasks which is resumed.
 @detailed Default value is 4. Values range is [1, 64].
 */
@property (nonatomic, assign, readwrite) NSUInteger numberOfResumedTasks;


/**
 @brief Number of concurrent tasks.
 @detailed Default value is 2. Values range is [1, 32].
 */
@property (nonatomic, assign, readwrite) NSUInteger numberOfMaximumConcurrentTasks;


/**
 @brief Checks is queue is cancelled.
 @return YES - if all tasks cancelled, othervice NO.
 */
- (BOOL) isCanceled;


/**
 @brief Add url for downloading.
 @param urlString The URL string for download. Can be nil.
 @param storePath Store path for downloaded data. Can be nil.
 @return YES - if successfully added, othervice NO.
 */
- (BOOL) addURLString:(NSString *) urlString withStorePath:(NSString *) storePath;


/**
 @brief Add url for downloading.
 @param url The URL for download. Can be nil. Also checked url is not file or file reference.
 @param storePath Store path for downloaded data. Can be nil.
 @return YES - if successfully added, othervice NO.
 */
- (BOOL) addURL:(NSURL *) url withStorePath:(NSString *) storePath;


/**
 @brief Starts queue.
 */
- (void) start;


/**
 @brief Cancel all tasks and waits when all tasks is canceled before triger handler.
 @param handler Handler triger on all tasks cancelled on 'main queue'. Can be NULL.
 */
- (void) cancelWithCompletionHandler:(void(^)(void)) handler;

@end


/**
 @brief Include queue serialization functionality
 */
#import "REDownloadTasksQueue+Serialization.h"

