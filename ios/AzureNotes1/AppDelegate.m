//
//  AppDelegate.m
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import "AppDelegate.h"
#import "WAConfiguration.h"

@interface AppDelegate ()
@property (strong, nonatomic) TaskService *_taskService;
@property (strong, nonatomic) MSClient *client;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    WAConfiguration * config =[WAConfiguration sharedConfiguration];
	if(!config)
    {
		UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Configuration Error"
                                                           message:@"You must update the ToolkitConfig section in the application's info.plist file before running the first time."
                                                          delegate:self
                                                 cancelButtonTitle:@"Close"
                                                 otherButtonTitles:nil];[alertView show];
		return YES;
	}
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
