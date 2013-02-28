//
//  TaskService.h
//  AzureTask
//
//  Created by Michael Lehman on 2/16/13.
//  Copyright (c) 2013 Developer Extraordinaire. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <Foundation/Foundation.h>


#pragma mark * Block Definitions


typedef void (^CompletionBlock) ();
typedef void (^CompletionWithIndexBlock) (NSUInteger index);
typedef void (^CompletionWithStringBlock) (NSString *value);
typedef void (^BusyUpdateBlock) (BOOL busy);


#pragma mark * TaskService public interface


@interface TaskService : NSObject<MSFilter>

@property (nonatomic, strong)   NSArray *items;
@property (nonatomic, strong)   NSMutableArray *tasks;
@property (nonatomic, strong)   MSClient *client;
@property (nonatomic, copy)     BusyUpdateBlock busyUpdate;

- (void) refreshDataOnSuccess:(CompletionBlock) completion;

- (void) addItem:(NSDictionary *) item
      completion:(CompletionWithStringBlock) completion;

- (void) updateItem: (NSDictionary *) item
           completion:(CompletionWithIndexBlock) completion;


- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse;

@end
