#import "UIApplication+WANetworkActivity.h"

static NSInteger wa_networkActivityCount = 0;

@implementation UIApplication (WANetworkActivity)

- (void)wa_refreshNetworkActivityIndicator 
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(wa_refreshNetworkActivityIndicator)
                               withObject:nil 
                            waitUntilDone:NO];
        return;
    }
    
    BOOL active = (self.wa_networkActivityCount > 0);
    self.networkActivityIndicatorVisible = active;
}

- (NSInteger)wa_networkActivityCount 
{
    @synchronized(self)
    {
        return wa_networkActivityCount;        
    }
}

- (void)wa_pushNetworkActivity 
{
    @synchronized(self)
    {
        wa_networkActivityCount++;
    }
    [self wa_refreshNetworkActivityIndicator];
}

- (void)wa_popNetworkActivity 
{
    @synchronized(self)
    {
        if (wa_networkActivityCount > 0)
        {
            wa_networkActivityCount--;
        }
        else
        {
            wa_networkActivityCount = 0;
        }        
    }
    [self wa_refreshNetworkActivityIndicator];
}

- (void)wa_resetNetworkActivity 
{
    @synchronized(self)
    {
        wa_networkActivityCount = 0;
    }
    [self wa_refreshNetworkActivityIndicator];        
}

@end
