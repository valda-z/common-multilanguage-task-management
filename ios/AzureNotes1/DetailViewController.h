//
//  DetailViewController.h
//  AzureNotes1
//
//  Created by Michael Lehman on 1/31/13.
//

#import <UIKit/UIKit.h>
#import "Task.h"
@interface DetailViewController : UIViewController
<UITextFieldDelegate,
UIImagePickerControllerDelegate>

@property (strong, nonatomic) Task  *detailItem;
@property (strong, nonatomic) id masterViewController;

@property BOOL addMode;

@end
