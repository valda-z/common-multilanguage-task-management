//
//  MasterViewController.m
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController ()
    @property (strong, nonatomic) NSMutableArray *tasks;
@end

@implementation MasterViewController

int taskNum = 1;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshData:)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) refreshData:(id)sender
{
    NSLog(@"Refresh data from Azure");
}

- (Task *) insertNewObject:(id)sender
{
    if (!self.tasks)
    {
        self.tasks = [[NSMutableArray alloc] init];
    }
    Task *newTask = [[Task alloc] init];
    newTask.name = [NSString stringWithFormat:@"Task %d", taskNum++];
    newTask.dueDate = [NSDate date];
    newTask.category = @"myPhone";
    newTask.isComplete = NO;
    
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
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Task *object = self.tasks[indexPath.row];
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tasks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


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
        Task *object = self.tasks[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
        [[segue destinationViewController] setMasterViewController:self];
        [[segue destinationViewController] setAddMode:NO];
    }
}

-(IBAction)sortByName:(id)sender
{
    [self.tasks sortUsingSelector:@selector(compareTaskName:)];
    [self.tableView reloadData];
    NSLog(@"Sort alpha");
}

-(IBAction)sortByDueDate:(id)sender
{
    [self.tasks sortUsingSelector:@selector(compareDueDate:)];
    [self.tableView reloadData];
    NSLog(@"Sort by date");
}

@end
