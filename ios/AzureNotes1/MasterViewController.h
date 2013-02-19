//
//  MasterViewController.h
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface MasterViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
- (Task *) insertNewObject:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
