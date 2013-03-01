#import <Foundation/Foundation.h>
#import "WABlobData.h"
@class WABlobHandler;

typedef void ( ^ WABlobResponseHandler)(NSError *error);

@interface WABlobHandler : NSObject
- (void)postImageToBlob:(WABlobData *)blobData
     withAuthenticationCredential:(WAAuthenticationCredential *)authenticationCredential
           usingCompletionHandler:(WABlobResponseHandler)block;

@end
