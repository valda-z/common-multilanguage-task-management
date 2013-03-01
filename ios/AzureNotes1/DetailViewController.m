//
//  DetailViewController.m
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "NSData+Base64.h"

#import "WABlobHandler.h"
#import "WAConfiguration.h"


//
// This #define controls whether images (attachments) are
//
// Saved as base64 encode images in the Azure Mobile Services table (value == 0)
//
//   or
//
// Saved in Azure Blob Storage (takes longer, handles bigger data) (value == 1)
//
#define SAVE_IMAGES_TO_BLOB_STORAGE 1


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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIImageView *chosenImage;
@property (strong, nonatomic) WABlobData * blobObject;
@property (strong, nonatomic) WAAuthenticationCredential *authenticationCredential;

-(void)postToBlobStorage;

@end

@implementation DetailViewController

bool editingTaskName = NO;
bool editingTaskCategory = NO;
bool editingTaskDate = NO;

#pragma mark - Managing the detail item

/////////////////////////////////////////////////////////////////////////////////
//
// Method called by the MasterView to set our data item
//
/////////////////////////////////////////////////////////////////////////////////
- (void)setDetailItem:(Task *)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

/////////////////////////////////////////////////////////////////////////////////
//
// Called when user toggles the Completed switch
//
/////////////////////////////////////////////////////////////////////////////////
- (IBAction)toggleCompletedAction:(id)sender
{
    self.detailItem.isComplete = self.taskCompleteSwitch.isOn;
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
}

/////////////////////////////////////////////////////////////////////////////////
//
// Called when the user wants to add an attachment
//
/////////////////////////////////////////////////////////////////////////////////
- (IBAction)addAttachment:(id)sender
{
    //self.detailItem.hasAttachment = YES;
    [self tapSelectImage:sender];
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
}

/////////////////////////////////////////////////////////////////////////////////
//
// Called to copy data from the self.detailItem Task object into the UX
//
/////////////////////////////////////////////////////////////////////////////////
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
    
    if (self.detailItem.hasAttachment)
    {
#if SAVE_IMAGES_TO_BLOB_STORAGE
        if ((NSNull *)self.detailItem.imageURL != [NSNull null])
        {
            UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.detailItem.imageURL]]];
            self.chosenImage.image = image;
        }
#else
        if (self.detailItem.imageAsBase64 != (id)[NSNull null])
        {
            NSData *data = [NSData dataFromBase64String:self.detailItem.imageAsBase64];
            UIImage *image = [UIImage imageWithData:data];
            self.chosenImage.image = image;
        }
#endif
    }
}

/////////////////////////////////////////////////////////////////////////////////
//
// Hookup the editing started/stopped events
//
/////////////////////////////////////////////////////////////////////////////////
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

/////////////////////////////////////////////////////////////////////////////////
//
// Implement logic for the save button.
// Take data from the self.detailItem, put it into a dictionary and send
// it to Mobile Services
//
/////////////////////////////////////////////////////////////////////////////////
- (IBAction)saveDataToAzure:(id)sender
{

#if SAVE_IMAGES_TO_BLOB_STORAGE
    if (self.blobObject.image != nil)
    {
        LOG(@"posting to Blob storage");
        [self postToBlobStorage];
    }
    else
#endif
        
        [self saveDataAfterBlobUpload:nil];
    
}

- (void) saveDataAfterBlobUpload:(NSString *)blobAddress
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *taskAsItem = [[NSMutableDictionary alloc] init];
    
    [taskAsItem setValue:[self.detailItem name] forKey:@"Name"];
    [taskAsItem setValue:[self.detailItem category] forKey:@"Category"];
    [taskAsItem setValue:[self.detailItem dueDate] forKey:@"DueDate"];
    [taskAsItem setValue:[self.detailItem isComplete] ? @"YES" : @"NO" forKey:@"IsComplete"];
    [taskAsItem setValue:[self.detailItem uniqueID] forKey:@"UniqueID"];
    [taskAsItem setValue:[self.detailItem idnum] forKey:@"id"];
    [taskAsItem setValue:[self.detailItem hasAttachment] ? @"YES" : @"NO" forKey:@"HasAttachment"];

#if SAVE_IMAGES_TO_BLOB_STORAGE
    if (blobAddress != nil)
        [taskAsItem setValue:blobAddress forKey:@"ImageURL"];
#endif
    
    //
    // Is this a CREATE (add)?
    //
    if ([self.detailItem.uniqueID isEqualToString:@""])
    {
        self.detailItem.uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
        [taskAsItem setValue:[self.detailItem uniqueID] forKey:@"UniqueID"];

#if !SAVE_IMAGES_TO_BLOB_STORAGE
        if (self.detailItem.hasAttachment)
        {
            //
            // we need to Base64 encode the image
            //
            NSData *data = nil;
            NSString *imageData = nil;
            if (self.chosenImage.image != nil)
            {
                UIImage *image = self.chosenImage.image;
                data = UIImagePNGRepresentation(image);
                imageData = [data base64EncodedString];
                self.detailItem.imageAsBase64 = imageData;
                [taskAsItem setValue:[self.detailItem imageAsBase64] forKey:@"ImageData"];
            }

        }
#endif
        
        [[appDelegate taskService] addItem:taskAsItem completion:^(NSString *value)
        {
            self.detailItem.idnum = value;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add complete" message:@"Task saved to Azure" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }];
    }
    else
    {
        //
        // No, this is an update
        //
        [[appDelegate taskService] updateItem:taskAsItem completion:^(NSUInteger index) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Update complete" message:@"Task saved to Azure" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }];
    }
}

#pragma mark Date Picker Methods


/////////////////////////////////////////////////////////////////////////////////
//
// This makes the date picker appear
//
// The first would be to create a whole additional view with just the
// date picker on it and a 'Done' button or,
// as we're doing here, simply put the date picker and done button on
// the same view but make them hidden by default and simply hide/show
// the appropriate controls at runtime
//
/////////////////////////////////////////////////////////////////////////////////
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (editingTaskCategory || editingTaskName)
        return NO;
    
    self.datePicker.hidden = NO;
    self.doneButton.hidden = NO;
    self.nameLabel.hidden = YES;
    self.taskNameField.hidden = YES;
    self.categoryLabel.hidden = YES;
    self.taskCategoryField.hidden = YES;
    self.dateLabel.hidden = YES;
    self.taskDateField.hidden = YES;
    editingTaskDate = YES;
    [self.saveButton setEnabled:NO];
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
    [self.saveButton setEnabled:YES];
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

#pragma mark - Text Field edit start/stop methods

- (IBAction)taskNameFieldStarted:(id)sender
{
    editingTaskName = YES;
    [self.saveButton setEnabled:NO];
}

- (IBAction) taskNameFieldDone:(id)sender
{
    self.detailItem.name = self.taskNameField.text;
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
    
    [self.taskNameField resignFirstResponder];
    editingTaskName = NO;
    [self.saveButton setEnabled:YES];
    [self.dateLabel setEnabled:YES];
}

- (IBAction)taskCategoryFieldStarted:(id)sender
{
    if (editingTaskName)
        return;
    
    editingTaskCategory = YES;
    [self.saveButton setEnabled:NO];
    [self.dateLabel setEnabled:NO];
}

- (IBAction) taskCategoryFieldDone:(id)sender
{
    self.detailItem.category = self.taskCategoryField.text;
    MasterViewController *mvc = (MasterViewController *)self.masterViewController;
    [mvc.tableView reloadData];
    
    [self.taskCategoryField resignFirstResponder];
    editingTaskCategory = NO;
    [self.saveButton setEnabled:YES];
    [self.dateLabel setEnabled:YES];
}

#pragma mark View appear/disappear handlers

/////////////////////////////////////////////////////////////////////////////////
//
// This method is called when the user taps on the navigation bar 'back' button
//
// Since we might be in the middle of editing a field, we must capture any data
// the user has already changed
//
/////////////////////////////////////////////////////////////////////////////////
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

    if (self.blobObject == nil)
    {
        self.blobObject =[[WABlobData alloc] init];
        
        //
        // TODO: Change this if you want
        //
        // This container is created under the Azure Storage 'Direct' account/key you setup
        // in the .plist file
        //
        self.blobObject.containerName = @"AzureTaskBlobContainer";
        self.blobObject.makeContainerPublic = YES;
        self.blobObject.blobName = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    
    if (self.authenticationCredential == nil)
    {
        
        WAConfiguration *config =[WAConfiguration sharedConfiguration];
        
        WAAuthenticationCredential *authenticationCredential =
        [WAAuthenticationCredential credentialWithAzureServiceAccount:config.accountName
                                                            accessKey:config.accessKey];
        
        
        self.authenticationCredential = authenticationCredential;
    }
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Photo/Video chooser

/////////////////////////////////////////////////////////////////////////////////
//
// Handle the "Add Photo/Video attachment" tap
//
/////////////////////////////////////////////////////////////////////////////////
- (IBAction)tapSelectImage:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = (id)self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma UIImagePickerControllerDelegate Methods

/////////////////////////////////////////////////////////////////////////////////
//
// Called when the user has selected an image from the Gallery
//
/////////////////////////////////////////////////////////////////////////////////
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    self.chosenImage.image = image;
    self.detailItem.hasAttachment = YES;
    self.blobObject.image = image;
    [picker dismissModalViewControllerAnimated:YES];
}

/////////////////////////////////////////////////////////////////////////////////
//
// When SAVE_IMAGES_TO_BLOB_STORAGE is set to 1, this method is called to
// upload the images to blob storage and get the resulting URL to add to the
// task for attachments.
//
// Note: This takes a considerably longer amount of time (to upload) but doesn't have
// the size limits of a column-encoded-as-base64 alternative
//
/////////////////////////////////////////////////////////////////////////////////

-(void)postToBlobStorage
{
    WABlobHandler *blobHandler =[[WABlobHandler alloc] init];
    [blobHandler postImageToBlob:self.blobObject
    withAuthenticationCredential:self.authenticationCredential
          usingCompletionHandler: ^ (NSError * error)
               {
                   if (error != nil)
                   {
                       UIAlertView *alert =
                       [[UIAlertView alloc] initWithTitle:@"Azure Blob Storage Error"
                                                  message:error.localizedDescription
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
                       [alert show];

                       return;
                   }
                   else
                   {
                       NSLog(@"Blob uploaded to Azure, URL is: %@",[self.blobObject.shortUrl absoluteString] );
                       [self saveDataAfterBlobUpload:[self.blobObject.shortUrl absoluteString]];
                   }
               }];    

}

@end
