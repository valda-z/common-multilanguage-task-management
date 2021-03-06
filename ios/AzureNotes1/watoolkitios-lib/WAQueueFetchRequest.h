/*
 Copyright 2010 Microsoft Corp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

@class WAResultContinuation;

/**
 A class that represents a Windows Azure Queue Storage fetch request.
 
 The request is used with the WACloudStorageClient when working with blobs.
 */
@interface WAQueueFetchRequest : NSObject

/**
 The name of the queue to fetch
 */
@property (nonatomic, copy) NSString *queueName;

/**
 Filters the results to return only queus whose names begin with the specified prefix. 
 */
@property (nonatomic, copy) NSString *prefix;

/**
 Specifies the maximum number of queues to return. If the request does not specify maxresults or specifies a value greater than 5,000, the server will return up to 5,000 items.
 */
@property (nonatomic, assign) NSUInteger maxResult;

/**
 The continuation to use in the fetch request.
 */
@property (nonatomic, retain) WAResultContinuation *resultContinuation;

/**
 Create a new WAQueueFetchRequest.
 
 @returns The newly initialized WAQueueFetchRequest object.
 */
+(WAQueueFetchRequest *)fetchRequest;

/**
 Create a new WAQueueFetchRequest with a result continuation.
 
 @param resultContinuation The continuation to use in the fetch request.
 
 @returns The newly initialized WAQueueFetchRequest object.
 */
+(WAQueueFetchRequest *)fetchRequestWithResultContinuation:(WAResultContinuation *)resultContinuation;

@end
