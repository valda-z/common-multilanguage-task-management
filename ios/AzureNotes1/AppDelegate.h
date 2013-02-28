//
//  AppDelegate.h
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "Task.h"
#import "TaskService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(TaskService *)taskService;
-(void)setTaskService:(TaskService *)taskService;

@end
