#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WABlobData : NSObject

@property (nonatomic, copy) NSString *containerName;
@property (nonatomic, copy) NSString *blobName;
@property (nonatomic, strong) NSURL *shortUrl;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL makeContainerPublic;

-(BOOL)isValid;
-(BOOL)isReady;
-(void)clear;
@end
