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
typedef NS_ENUM(NSUInteger, REDownloadTasksQueueReportType) {
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
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueProgressChangedNotification;


/**
 @brief Arrived when download progress changed.
 User info dictionary is: @{@"queue" : REDownloadTasksQueue, @"userObject" : UserObject, @"progress" : NSNumberValue}.
 @warning Key = kREDownloadTasksQueueQueueKey; Value = REDownloadTasksQueue object.
 @warning Key = kREDownloadTasksQueueUserObjectKey;  Value = user object or [NSNull null]
 @warning Key = kREDownloadTasksQueueDownloadURLKey; Value = 'NSURL' object.
 @warning Key = kREDownloadTasksQueueStoreURLKey; Value = 'NSURL' object.
 @warning Key = kREDownloadTasksQueueProgressKey;  Value = 'NSNumber' object.
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueDidDownloadURLProgressChangedNotification;


/**
 @brief Arrived on error.
 User info dictionary is: @{@"queue" : REDownloadTasksQueue, @"userObject" : UserObject, @"error" : NSError object, @"downloadURL" : NSURL object, @"storeURL" : NSURL object}. 
 @warning Key = kREDownloadTasksQueueQueueKey; Value = DownloadTasksQueue object.
 @warning Key = kREDownloadTasksQueueUserObjectKey;  Value = user object or [NSNull null]
 @warning Key = kREDownloadTasksQueueErrorKey; Value = 'NSError' object.
 @warning Key = kREDownloadTasksQueueDownloadURLKey; Value = 'NSURL' object.
 @warning Key = kREDownloadTasksQueueStoreURLKey; Value = 'NSURL' object.
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueErrorNotification;


/**
 @brief Arrived on all tasks done.
 User info dictionary is: @{@"queue" : REDownloadTasksQueue, @"userObject" : UserObject }. 
 @warning Key = kREDownloadTasksQueueQueueKey; Value = DownloadTasksQueue object.
 @warning Key = kREDownloadTasksQueueUserObjectKey;  Value = user object or [NSNull null]
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueDidFinishedNotification;


/**
 @brief Key used for download queue.
 @detailed Value is @"queue".
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueQueueKey;


/**
 @brief Key used for download progress.
 @detailed Value is @"progress".
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueProgressKey;


/**
 @brief Key used for queue user object.
 @detailed Value is @"userObject".
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueUserObjectKey;


/**
 @brief Key used for queue error.
 @detailed Value is @"error".
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueErrorKey;


/**
 @brief Key used for store file URL object. To URL.
 @detailed Value is @"storeURL".
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueStoreURLKey;


/**
 @brief Key used for download URL object. From URL.
 @detailed Value is @"downloadURL".
 */
RE_EXTERN NSString * const _Nonnull kREDownloadTasksQueueDownloadURLKey;


@class REDownloadTasksQueue;


/**
 @brief Protocol of the download rasks queue delegate. All methods are optinal and called from 'main queue'.
 @detailed Delegate will called only if available.
 */
@protocol REDownloadTasksQueueDelegate <NSObject>

@optional
/**
 @brief Called when all queue tasks finished.
 @param queue The download queue object.
 */
- (void) onREDownloadTasksQueueFinished:(nonnull REDownloadTasksQueue *) queue;


/**
 @brief Called when downloading progress changed.
 @param queue The download queue object.
 @param progress Downloading progress in range from 0 to 1, [0, 1].
 */
- (void) onREDownloadTasksQueue:(nonnull REDownloadTasksQueue *) queue
					   progress:(float) progress;


/**
 @brief Called when downloaded single url and stored to destination path
 @param queue The download queue object.
 @param downloadURL Downloaded URL.
 @param storeURL URL for storing downloaded data.
 @param progress Downloading progress in range from 0 to 1, [0, 1].
 */
- (void) onREDownloadTasksQueue:(nonnull REDownloadTasksQueue *) queue
				 didDownloadURL:(nullable NSURL *) downloadURL
				 andStoredToURL:(nullable NSURL *) storeURL
				   withProgress:(float) progress;


/**
 @brief Called when error oqupaed.
 @param queue The download queue object.
 @param error The error object.
 @param downloadURL Downloaded URL.
 @param storeURL URL for storing downloaded data.
 */
- (void) onREDownloadTasksQueue:(nonnull REDownloadTasksQueue *) queue
						  error:(nullable NSError *) error
					downloadURL:(nullable NSURL *) downloadURL
					   storeURL:(nullable NSURL *) storeURL;

@end


/**
 @brief Class of the queue based on NSURLSessionDownloadTask tasks.
 */
@interface REDownloadTasksQueue : NSObject


/**
 @brief Weak queue delegate.
 */
@property (nonatomic, weak, nullable) id<REDownloadTasksQueueDelegate> delegate;


/**
 @brief Type of reporting using binary OR flags. Use REDownloadTasksQueueReportType values.
 @detailed Default is both methods for reporting and will be used if available.
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
@property (nonatomic, strong, nullable) id userObject;


/**
 @brief Number of tasks in the queue. 
 @detailed During downloading this value is decrementing, when some task successfully finished.
 */
@property (nonatomic, assign, readonly) NSUInteger tasksCount;


/**
 @brief Should queue continue when task error occupied.
 @detained Default is NO.
 */
@property (nonatomic, assign, readwrite) BOOL continueOnTaskError;

/**
 @brief Block handler for reporting queue download progress. Can be NULL.
 @detailed Arrived on 'main queue'.
 @warning Used ONLY if 'REDownloadTasksQueueReportViaBlocks' type present in 'reportType' property.
 */
@property (nonatomic, copy, nullable) void(^onProgressHandler)(REDownloadTasksQueue * _Nonnull queue, float progress);


/**
 @brief Block handler for reporting queue download progress. Can be NULL.
 @detailed Arrived on 'main queue'.
 @param downloadURL Downloaded URL.
 @param storeURL URL for storing downloaded data.
 @warning Used ONLY if 'REDownloadTasksQueueReportViaBlocks' type present in 'reportType' property.
 */
@property (nonatomic, copy, nullable) void(^onDidDownloadURLProgressHandler)(REDownloadTasksQueue * _Nonnull queue, NSURL * _Nullable downloadURL, NSURL * _Nullable storeURL, float progress);


/**
 @brief Block handler for reporting queue finished work(all tasks successfully finished).
 @detailed Arrived on 'main queue'.
 @warning Used ONLY if 'REDownloadTasksQueueReportViaBlocks' type present in 'reportType' property.
 */
@property (nonatomic, copy, nullable) void(^onFinishedHandler)(REDownloadTasksQueue * _Nonnull queue);


/**
 @brief Block handler for reporting queue error. Before this, queue is cancelled.
 @detailed Arrived on 'main queue'.
 @warning Used ONLY if 'REDownloadTasksQueueReportViaBlocks' type present in 'reportType' property.
 */
@property (nonatomic, copy, nullable) void(^onErrorOccurredHandler)(REDownloadTasksQueue * _Nonnull queue, NSError * _Nullable error, NSURL * _Nullable downloadURL, NSURL * _Nullable storeFilePathURL);


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
- (BOOL) addURLString:(nullable NSString *) urlString withStorePath:(nullable NSString *) storePath;


/**
 @brief Add url for downloading.
 @param url The URL for download. Can be nil. Also checked url is not file or file reference.
 @param storePath Store path for downloaded data. Can be nil.
 @return YES - if successfully added, othervice NO.
 */
- (BOOL) addURL:(nullable NSURL *) url withStorePath:(nullable NSString *) storePath;


/**
 @brief Add url request for downloading.
 @param urlRequest Manually setuped URL request. Can be nil. Also checked request url is not file or file reference.
 @param storePath Store path for downloaded data. Can be nil.
 @return YES - if successfully added, othervice NO.
 */
- (BOOL) addURLRequest:(nullable NSURLRequest *) urlRequest withStorePath:(nullable NSString *) storePath;


/**
 @brief Starts queue.
 @warning Don't forget call cancelWithCompletionHandler: method if queue not correctly finished.
 */
- (void) start;


/**
 @brief Cancel all tasks and waits untill all tasks is canceled before triger handler.
 @warning You shoul always call this method if you want to release queue, cause internal session object
 holds strongly this queue.
 @param handler Handler triger on all tasks cancelled on 'main queue'. Can be NULL.
 */
- (void) cancelWithCompletionHandler:(nullable void(^)(void)) handler;

@end


/**
 @brief Include queue serialization functionality
 */
#import "REDownloadTasksQueue+Serialization.h"

