//
//  Task.m
//  AzureNotes1
//
//  Created by Michael Lehman on 2/5/13.
//  Copyright (c) 2013 Developer Extraordinaire. All rights reserved.
//

#import "Task.h"

@interface Task ()
@end

@implementation Task

@synthesize name;
@synthesize category;
@synthesize hasAttachment;
@synthesize dueDate;
@synthesize isComplete;
@synthesize uniqueID;
@synthesize idnum;
@synthesize imageAsBase64;
@synthesize imageURL;


/////////////////////////////////////////////////////////////////////////////////
//
// compareTaskName - so we can use sortUsingSelector
//
/////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult) compareTaskName:(Task *) task
{
    return [name compare:[task name] options:NSCaseInsensitiveSearch];
}

/////////////////////////////////////////////////////////////////////////////////
//
// compareDueDate - so we can use sortUsingSelector but based on dueDate
//
/////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult) compareDueDate:(Task *) task
{
    NSDate *thisFileDate = [self dueDate];
    NSDate *mediaFileDate = [task dueDate];
    
    return [thisFileDate compare:mediaFileDate];
}

@end
