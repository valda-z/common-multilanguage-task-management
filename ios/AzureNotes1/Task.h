//
//  Task.h
//  AzureNotes1
//
//  Created by Michael Lehman on 2/5/13.
//  Copyright (c) 2013 Developer Extraordinaire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSDate *dueDate;
@property BOOL hasAttachment;
@property BOOL isComplete;
@end
