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

/**
 @brief Serialization and deserialization features.
 */
@interface REDownloadTasksQueue (Serialization)

/**
 @brief Cancel all tasks and serialize left(unfinished) tasks and returns restoration identifier.
 @detailed Store tasks localy for future resuming with restoration identifier(you should keep it).
 When you call this method you will return immediately and serialization will continue in 'background queue'.
 And after finishing handler will be called in 'main queue'
 @param handler Handler for informing done serializing with restoration identifier. If handler is nil - do nothing.
 */
- (void) cancelAndSerializeWithRestorationID:(nonnull void(^)(NSString * _Nonnull restorationID)) handler;


/**
 @brief Creates new queue from stored restoration data by it's identifier.
 When you call this method you will return immediately and creating/restoring will continue in 'high priority queue'.
 And after finishing handler will be called in 'main queue'
 @param restorationID Stored tasks restoration identifier goted from 'cancelAndSerializeWithRestorationID' or 'allRestorationIDs' methods.
 @param handler Completion handler returned restored queue.
 */
+ (void) createWithRestorationID:(nonnull NSString *) restorationID
			andCompletionHandler:(nonnull void(^)(REDownloadTasksQueue * _Nonnull queue, NSError * _Nullable error)) handler;


/**
 @brief Return all stored restoration identifiers.
 @return Array with restoration identifier strings or nil if nothing present.
 */
+ (nullable NSArray *) allRestorationIDs;


/**
 @brief Deletes stored data asociated with restoration identifier.
 @detailed After calling this method restoration identifier will be unused.
 @param restorationID The restoration restoration identifier goted by 'cancelAndSerializeWithRestorationID' or
 'allRestorationIDs' methods.
 */
+ (void) removeRestorationIdentifier:(nonnull NSString *) restorationID;

@end
