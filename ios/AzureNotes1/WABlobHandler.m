#import "WABlobHandler.h"


@implementation WABlobHandler

- (void)postImageToBlob:(WABlobData *)blobObject
withAuthenticationCredential:(WAAuthenticationCredential *)authenticationCredential
 usingCompletionHandler:(WABlobResponseHandler)block
{
    WACloudStorageClient *addContainerClient =[WACloudStorageClient storageClientWithCredential:authenticationCredential];
    
    WABlobContainer *containerToAdd =[[WABlobContainer alloc] initContainerWithName:blobObject.containerName];
    containerToAdd.isPublic = blobObject.makeContainerPublic;
    containerToAdd.createIfNotExists = YES;
    
    //
    // First, we have to get access to the container.
    // Let's try to create it and, if we get any error OTHER THAN "ContainerAlreadyExists" we abort
    //
    [addContainerClient addBlobContainer:containerToAdd
                   withCompletionHandler: ^ (NSError * error)
    {
        //
        // Check to make sure we've either created the container or can get access to the existing container
        //
        if (error != nil)
        {
            // check to see that the blob is not already created. This only matters in a direct connection scenario
            NSString *code =[[error userInfo] objectForKey:WAErrorReasonCodeKey];
            if ([code isEqualToString:@"ContainerAlreadyExists"] == NO)
            {
                block(error);
                return;
            }
        }
        
        //
        // Ok, we're good, let's get access to the container
        //
        WACloudStorageClient *fetchContainerClient =[WACloudStorageClient storageClientWithCredential:authenticationCredential];
        
        [fetchContainerClient fetchBlobContainerNamed:containerToAdd.name
                                withCompletionHandler: ^ (WABlobContainer * container, NSError * error)
                                                                                                                                
        {
            //
            // Any error attempting to connect to the container is a failure
            //
            if (error != nil)
            {
                block(error);
                return;
            }
            
            //
            // Now that we've got access to the container, let's build up the blob
            //
            WABlob *blob =[[WABlob alloc] initBlobWithName:blobObject.blobName
                                                       URL:nil
                                             containerName:container.name];
            
            //
            // In this method, everything we upload is an image
            //
            blob.contentType = @"image/jpeg";
            blob.contentData = UIImageJPEGRepresentation(blobObject.image, 1.0);
            
            [blob setValue:@"image/jpeg" forMetadataKey:@"ImageType"];
            
            WACloudStorageClient *addBlobClient =
                [WACloudStorageClient storageClientWithCredential:authenticationCredential];
            
            //
            // OK, time to upload it
            //
            [addBlobClient addBlob:blob
                       toContainer:container
             withCompletionHandler: ^ (NSError * error)
            {
                //
                // Again, any error at this point is 'fatal'
                //
                if (error != nil)
                {
                    block(error);
                    return;
                }
                
                //
                // Now, we go fetch it in order to get it's URL
                //
                WABlobFetchRequest *request =
                    [WABlobFetchRequest fetchRequestWithContainer:container resultContinuation:nil];
                
                request.prefix = blob.name;
                
                WACloudStorageClient *fetchBlobClient =
                    [WACloudStorageClient storageClientWithCredential:authenticationCredential];
                                                                                                                                  
                                                                                                                                  
              [fetchBlobClient fetchBlobsWithRequest:request
                              usingCompletionHandler: ^ (NSArray * blobs, WAResultContinuation * resultContinuation, NSError * error)
                {
                    //
                    // Again, any error at this point is 'fatal'
                    //
                    if (error != nil)
                    {
                        block(error);
                        return;
                    }

                    WABlob *blobToShorten =[blobs objectAtIndex:0];
                    blobObject.shortUrl = blobToShorten.URL;
                    block(nil);
                }];
            }];
        }];
    }];
}

@end
