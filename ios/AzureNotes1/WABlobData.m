#import "WABlobData.h"

static NSString * const kContainerName = @"containername";

@implementation WABlobData

@synthesize containerName = _containerName;
@synthesize blobName;
@synthesize shortUrl;
@synthesize image;

-(id)init
{
    self =[super init];
    if (self)
    {
        _containerName =[[NSUserDefaults standardUserDefaults] valueForKey:kContainerName];
        _makeContainerPublic = YES;
    }
    return self;
}

- (void)setContainerName:(NSString *)contanerName
{
    _containerName =[contanerName copy];[[NSUserDefaults standardUserDefaults] setValue:_containerName forKey:kContainerName];
}

- (BOOL)isValid
{
    if (self.containerName.length == 0 || self.blobName.length == 0 || self.image == nil)
    {
        return NO;
    }
    return YES;
}

- (BOOL)isReady
{
    return (self.shortUrl != nil);
}

- (void)clear
{
    self.blobName = nil;
    self.image = nil;
    self.shortUrl = nil;
}

@end
