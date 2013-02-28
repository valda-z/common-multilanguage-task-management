//
//  AppDelegate.m
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong, nonatomic) TaskService *_taskService;
@property (strong, nonatomic) MSClient *client;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

/////////////////////////////////////////////////////////////////////////////////
//
// Custom getter/setter for taskService
//
/////////////////////////////////////////////////////////////////////////////////
-(void)setTaskService:(TaskService *)taskService
{
    self._taskService = taskService;
}

-(TaskService *)taskService
{
    return self._taskService;
}


@end
