//
//  TaskService.m
//  AzureTask
//
//  Created by Michael Lehman on 2/16/13.
//  Copyright (c) 2013 Developer Extraordinaire. All rights reserved.
//

#import "TaskService.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "Task.h"

#pragma mark * Private interace


@interface TaskService()

@property (nonatomic, strong)   MSTable *table;
@property (nonatomic)           NSInteger busyCount;

@end


#pragma mark * Implementation


@implementation TaskService

@synthesize items;
@synthesize tasks;

/////////////////////////////////////////////////////////////////////////////////
//
// Connect to Azure Mobile Services
//
/////////////////////////////////////////////////////////////////////////////////
-(TaskService *) init
{
    self = [super init];
    if (self) {
        // Initialize the Mobile Service client with your URL and key
        MSClient *newClient = [MSClient clientWithApplicationURLString:@"https://azuretask1.azure-mobile.net/"
                                                    withApplicationKey:@"QKXDcCREVtxnyKYnhsOyawbqjyoJcz61"];
        
        // Add a Mobile Service filter to enable the busy indicator
        self.client = [newClient clientwithFilter:self];
        
        // Create an MSTable instance to allow us to work with the Item table
        self.table = [_client getTable:@"Item"];
        
        self.items = [[NSMutableArray alloc] init];
        self.busyCount = 0;
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////////////////////
//
// Get the table data from Azure
//
/////////////////////////////////////////////////////////////////////////////////
- (void) refreshDataOnSuccess:(CompletionBlock)completion
{
    // Create a predicate that finds items where complete is false
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"UniqueID != ''"];
    
    // Query the Item table and update the items property with the results from the service
    [self.table readWhere:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error)
    {
        
        [self logErrorIfNotNil:error];
        
        items = [results mutableCopy];
        tasks = [[NSMutableArray alloc] init];
        for (NSDictionary *d in items)
        {
            Task *newTask = [[Task alloc] init];

            newTask.idnum = [d objectForKey:@"id"];
            newTask.name = [d objectForKey:@"Name"];
            newTask.category = [d objectForKey:@"Category"];
            newTask.dueDate = [d objectForKey:@"DueDate"];
            newTask.isComplete = [[d objectForKey:@"IsComplete"] isEqualToString:@"YES"] ? YES : NO;
            newTask.uniqueID = [d objectForKey:@"UniqueID"];
            newTask.imageAsBase64 = [d objectForKey:@"ImageData"];
            newTask.hasAttachment = [[d objectForKey:@"HasAttachment"] isEqualToString:@"YES"] ? YES : NO;
            [tasks addObject:newTask];
        }
        
        // Let the caller know that we finished
        completion();
    }];
    
}

/////////////////////////////////////////////////////////////////////////////////
//
// Add a new row to the DB
//
/////////////////////////////////////////////////////////////////////////////////
-(void) addItem:(NSDictionary *)item completion:(CompletionWithStringBlock)completion
{
    // Insert the item into the Item table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        NSUInteger index = [items count];
        [(NSMutableArray *)items insertObject:result atIndex:index];
        
        tasks = [[NSMutableArray alloc] init];
        for (NSDictionary *d in items)
        {
            Task *newTask = [[Task alloc] init];
            
            newTask.idnum = [d objectForKey:@"id"];
            newTask.name = [d objectForKey:@"Name"];
            newTask.category = [d objectForKey:@"Category"];
            newTask.dueDate = [d objectForKey:@"DueDate"];
            newTask.isComplete = [[d objectForKey:@"IsComplete"] isEqualToString:@"YES"] ? YES : NO;
            newTask.uniqueID = [d objectForKey:@"UniqueID"];
            newTask.imageAsBase64 = [d objectForKey:@"ImageData"];
            newTask.hasAttachment = [[d objectForKey:@"HasAttachment"] isEqualToString:@"YES"] ? YES : NO;
            [tasks addObject:newTask];
        }
        
        // Let the caller know that we finished
        completion([result objectForKey:@"id"]);
    }];
}

/////////////////////////////////////////////////////////////////////////////////
//
// Update an item already in the table
//
/////////////////////////////////////////////////////////////////////////////////
-(void) updateItem:(NSDictionary *)item completion:(CompletionWithIndexBlock)completion
{
    // Cast the public items property to the mutable type (it was created as mutable)
    NSMutableArray *mutableItems = (NSMutableArray *) items;
    
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [item mutableCopy];
    
    // Replace the original in the items array
    NSUInteger index = 0;
    for(NSMutableDictionary *d in items)
    {
        if ([[d valueForKey:@"UniqueID"] isEqualToString:[item valueForKey:@"UniqueID"]])
        {
            break;
        }
        index++;
    }
    
    [mutableItems replaceObjectAtIndex:index withObject:mutable];
    
    // Update the item in the Item table and remove from the items array on completion
    [self.table update:mutable completion:^(NSDictionary *item, NSError *error)
    {
        
        [self logErrorIfNotNil:error];
                
        // Let the caller know that we have finished
        completion(index);
    }];
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

- (void) busy:(BOOL) busy
{
    // assumes always executes on UI thread
    if (busy) {
        if (self.busyCount == 0 && self.busyUpdate != nil)
        {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil)
        {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}


#pragma mark * MSFilter methods

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse
{
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
    {
        [self busy:NO];
        onResponse(response, data, error);
    };
    
    // Increment the busy counter before sending the request
    [self busy:YES];
    onNext(request, wrappedResponse);
}

@end
