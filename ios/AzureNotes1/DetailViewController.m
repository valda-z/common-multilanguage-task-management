//
//  DetailViewController.m
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import "DetailViewController.h"
#import "MasterViewController.h"

@interface DetailViewController ()
- (void)configureView;
@property (strong, nonatomic) IBOutlet UITextField *taskNameField;
@property (strong, nonatomic) IBOutlet UITextField *taskCategoryField;
@property (strong, nonatomic) IBOutlet UITextField *taskDateField;
@property (strong, nonatomic) IBOutlet UISwitch *taskCompleteSwitch;
@property (strong, nonatomic) IBOutlet UIButton *addAttachmentButton;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation DetailViewController

bool editingTaskName = NO;
bool editingTaskCategory = NO;
bool editingTaskDate = NO;

#pragma mark - Managing the detail item

- (void)setDetailItem:(Task *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}
- (IBAction)toggleCompletedAction:(id)sender
{
    self.detailItem.isComplete = self.taskCompleteSwitch.isOn;
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
}

- (IBAction)addAttachment:(id)sender
{
    self.detailItem.hasAttachment = YES;
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
}

- (void)configureView
{
    [self.taskNameField setText:self.detailItem.name];
    [self.taskCategoryField setText:self.detailItem.category];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterLongStyle];
    
    
    NSString *dateString = [format stringFromDate:self.detailItem.dueDate];

    [self.taskDateField setText:dateString];
    
    [self.taskCompleteSwitch setOn:self.detailItem.isComplete];
    
    if (!self.addMode)
        self.addAttachmentButton.hidden = YES;
}

- (IBAction)attachDeleteButtonTapped:(id)sender
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.taskNameField addTarget:self
                           action:@selector(taskNameFieldDone:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.taskNameField addTarget:self
                           action:@selector(taskNameFieldStarted:)
                 forControlEvents:UIControlEventEditingDidBegin];
    
    [self.taskCategoryField addTarget:self
                           action:@selector(taskCategoryFieldDone:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.taskCategoryField addTarget:self
                           action:@selector(taskCategoryFieldStarted:)
                 forControlEvents:UIControlEventEditingDidBegin];
    
    [self.taskDateField setDelegate:self];
}

//
// This makes the date picker appear
//
// The first would be to create a whole additional view with just the
// date picker on it and a 'Done' button or,
// as we're doing here, simply put the date picker and done button on
// the same view but make them hidden by default and simply hide/show
// the appropriate controls at runtime
//
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.datePicker.hidden = NO;
    self.doneButton.hidden = NO;
    self.nameLabel.hidden = YES;
    self.taskNameField.hidden = YES;
    self.categoryLabel.hidden = YES;
    self.taskCategoryField.hidden = YES;
    self.dateLabel.hidden = YES;
    self.taskDateField.hidden = YES;
    editingTaskDate = YES;
    return NO;
}

- (IBAction)doneButtonTapped:(id)sender
{
    self.nameLabel.hidden = NO;
    self.taskNameField.hidden = NO;
    self.categoryLabel.hidden = NO;
    self.taskCategoryField.hidden = NO;
    self.dateLabel.hidden = NO;
    self.taskDateField.hidden = NO;
    self.datePicker.hidden = YES;
    self.doneButton.hidden = YES;
    editingTaskDate = NO;
    //
    // Now, extract the current date setting from the
    // date picker and fill in both the on-screen text field
    // and the data object
    //
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterLongStyle];
    
    
    NSString *dateString = [format stringFromDate:self.datePicker.date];

    self.taskDateField.text = dateString;
    self.detailItem.dueDate = self.datePicker.date;
    
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
}

- (IBAction)taskNameFieldStarted:(id)sender
{
    editingTaskName = YES;
}

- (IBAction) taskNameFieldDone:(id)sender
{
    self.detailItem.name = self.taskNameField.text;
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
    
    [self.taskNameField resignFirstResponder];
    editingTaskName = NO;
}

- (IBAction)taskCategoryFieldStarted:(id)sender
{
    editingTaskCategory = YES;
}

- (IBAction) taskCategoryFieldDone:(id)sender
{
    self.detailItem.category = self.taskCategoryField.text;
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
    
    [self.taskCategoryField resignFirstResponder];
    editingTaskCategory = NO;
}

//
// This method is called when the user taps on the navigation bar 'back' button
//
// Since we might be in the middle of editing a field, we must capture any data
// the user has already changed
//
- (void)viewWillDisappear:(BOOL)animated
{
    if (editingTaskName)
        self.detailItem.name = self.taskNameField.text;

    if (editingTaskCategory)
        self.detailItem.category = self.taskCategoryField.text;
    
    if (editingTaskDate)
    {
        self.detailItem.dueDate = self.datePicker.date;
    }

    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
