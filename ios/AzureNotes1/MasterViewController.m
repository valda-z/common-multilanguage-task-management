//
//  MasterViewController.m
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "TaskService.h"

@interface MasterViewController ()
    @property (strong, nonatomic) NSMutableArray *tasks;
    @property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
    @property (strong, nonatomic) TaskService *taskService;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

/////////////////////////////////////////////////////////////////////////////////
//
// Handle the wakeup call when our view is loaded
//
/////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    // Add the Refresh button to the toolbar
    //
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshData:)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    //
    // Indicate that this class (self) is the delegate and source for the TableView
    //
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    //
    // Create the taskService - this creates the Azure Mobile Service client inside the wrapped service
    //
    self.taskService = [[TaskService alloc]init];
    
    //
    // And assign it to the appDelegate so we can access it in the DetailViewController
    //
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTaskService:self.taskService];

    
    //
    // Now, download the current state of the data from Azure
    //
    UIActivityIndicatorView *indicator = self.activityIndicator;
    self.taskService.busyUpdate = ^(BOOL busy) {
        if (busy) {
            [indicator startAnimating];
        } else {
            [indicator stopAnimating];
        }
    };
    
    [self.taskService refreshDataOnSuccess:^{
        [self.tableView reloadData];
    }];

}

/////////////////////////////////////////////////////////////////////////////////
//
// Handle the tap on the Refresh button
// Go get the data from Azure again (in case someone adjusted it from another instance of the app
//
/////////////////////////////////////////////////////////////////////////////////
- (void) refreshData:(id)sender
{
    UIActivityIndicatorView *indicator = self.activityIndicator;
    self.taskService.busyUpdate = ^(BOOL busy) {
        if (busy) {
            [indicator startAnimating];
        } else {
            [indicator stopAnimating];
        }
    };
    
    [self.taskService refreshDataOnSuccess:^{
        [self.tableView reloadData];
    }];
}

/////////////////////////////////////////////////////////////////////////////////
//
// Add a new task
//
/////////////////////////////////////////////////////////////////////////////////
- (Task *) insertNewObject:(id)sender
{
    if (!self.tasks)
    {
        self.tasks = [[NSMutableArray alloc] init];
    }

    Task *newTask = [[Task alloc] init];
    newTask.name = @"New Task";
    newTask.dueDate = [NSDate date];
    newTask.category = @"Tasks";
    newTask.isComplete = NO;
    newTask.uniqueID = @"";

    [self.tasks insertObject:newTask atIndex:0];
    [self.tableView reloadData];
    return newTask;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.taskService.tasks == nil)
        return 0;
    else
        return [self.taskService.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    //
    // Note:  We get the data from the service
    //
    Task *object = [self.taskService.tasks objectAtIndex:indexPath.row];

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = object.name;
    
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:2];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterLongStyle];
    
        
    NSString *dateString = [format stringFromDate:object.dueDate];

    detailLabel.text = [NSString stringWithFormat:@"%@ - %@",object.category, dateString];
    
    UIImageView *checkBox = (UIImageView *) [cell viewWithTag:3];
    [checkBox setHidden:!object.isComplete];
    
    UIImageView *paperClip = (UIImageView *) [cell viewWithTag:4];
    [paperClip setHidden:!object.hasAttachment];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/////////////////////////////////////////////////////////////////////////////////
//
// This is where the 'magic' of storyboards happens
//
// We are called for adding a task, or viewing an existing task
//
/////////////////////////////////////////////////////////////////////////////////
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@",[segue identifier]);
    
    
    if ([[segue identifier] isEqualToString:@"addItem"])
    {
        Task *newTask = [self insertNewObject:nil];
        [[segue destinationViewController] setDetailItem:newTask];
        [[segue destinationViewController] setMasterViewController:self];
        [[segue destinationViewController] setAddMode:YES];
    }

    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        Task *object = [self.taskService.tasks objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
        [[segue destinationViewController] setMasterViewController:self];
        [[segue destinationViewController] setAddMode:NO];
    }
}

/////////////////////////////////////////////////////////////////////////////////
//
// Implement sort by name
//
/////////////////////////////////////////////////////////////////////////////////
-(IBAction)sortByName:(id)sender
{
    [self.taskService.tasks sortUsingSelector:@selector(compareTaskName:)];
    [self.tableView reloadData];
    NSLog(@"Sort alpha");
}

/////////////////////////////////////////////////////////////////////////////////
//
// Implement sort by due date
/////////////////////////////////////////////////////////////////////////////////
-(IBAction)sortByDueDate:(id)sender
{
    [self.taskService.tasks sortUsingSelector:@selector(compareDueDate:)];
    [self.tableView reloadData];
    NSLog(@"Sort by date");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
