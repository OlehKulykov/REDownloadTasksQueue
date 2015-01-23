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


#if (defined(DEBUG) || defined(_DEBUG)) && !defined(_DEBUG_LOG) && !defined(_DEBUG_LOGA)
#  define _DEBUG_LOG(s) NSLog(s); 
#  define _DEBUG_LOGA(s, ...) NSLog(s, ##__VA_ARGS__); 
#else
#  define _DEBUG_LOG(s)  
#  define _DEBUG_LOGA(s, ...)  
#endif


typedef NS_ENUM(NSUInteger, REDownloadTasksQueueReportType) 
{
	/**
	 @brief Silent mode.
	 */
	REDownloadTasksQueueReportNone = 0,
	
	/**
	 @brief Reporting using 'NSNotificationCenter defaultCenter'.
	 */
	REDownloadTasksQueueReportViaNotifications = 1 << 0,
	
	
	/**
	 @brief Reporting using blocks.
	 */
	REDownloadTasksQueueReportViaBlocks = 1 << 1
};


/**
 @brief 40 sec.
 */
RE_EXTERN const NSTimeInterval kREDownloadTasksQueueDefaultRequestTimeout;


/**
 @brief NSURLRequestReloadIgnoringCacheData.
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
 @brief @"queue"
 */
RE_EXTERN NSString * const kREDownloadTasksQueueQueueKey;


/**
 @brief @"progress"
 */
RE_EXTERN NSString * const kREDownloadTasksQueueProgressKey;


/**
 @brief @"userObject"
 */
RE_EXTERN NSString * const kREDownloadTasksQueueUserObjectKey;


/**
 @brief @"error"
 */
RE_EXTERN NSString * const kREDownloadTasksQueueErrorKey;


/**
 @brief @"storeURL"
 */
RE_EXTERN NSString * const kREDownloadTasksQueueStoreURLKey;


@interface REDownloadTasksQueue : NSObject

/**
 @brief Type of reporting using binary OR flags. DownloadTasksQueueReportType
 @detailed Default is both methods for reporting.
 */
@property (nonatomic, assign, readwrite) NSUInteger reportType;


/**
 @brief Default value is kREDownloadTasksQueueDefaultRequestCachePolicy.
 */
@property (nonatomic, assign, readwrite) NSURLRequestCachePolicy cachePolicy;


/**
 @brief  Default value kREDownloadTasksQueueDefaultRequestTimeout.
 */
@property (nonatomic, assign, readwrite) NSTimeInterval timeoutInterval;


/**
 @brief Default is 0. Value between 0 and 1, [0, 1].
 */
@property (nonatomic, assign, readonly) float downloadProgress;


/**
 @brief Default is [NSNull null].
 */
@property (nonatomic, strong) id userObject;

@property (nonatomic, assign, readonly) NSUInteger tasksCount;

@property (nonatomic, copy) void(^onProgressHandler)(REDownloadTasksQueue * queue, float progress);

@property (nonatomic, copy) void(^onFinishedHandler)(REDownloadTasksQueue * queue);

@property (nonatomic, copy) void(^onErrorOccurredHandler)(REDownloadTasksQueue * queue, NSError * error, NSURL * storeFilePathURL);

@property (nonatomic, assign, readwrite) NSUInteger numberOfParallelTasks;

- (BOOL) isCanceled;

- (BOOL) addURLString:(NSString *) urlString withStorePath:(NSString *) storePath;

- (BOOL) addURL:(NSURL *) url withStorePath:(NSString *) storePath;

- (void) start;

- (void) cancelWithCompletionHandler:(void(^)(void)) handler;

@end


/**
 @brief Include queue serialization functionality
 */
#import "REDownloadTasksQueue+Serialization.h"

