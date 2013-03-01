#import <UIKit/UIKit.h>

@interface UIApplication (WANetworkActivity)

@property (nonatomic, assign, readonly) NSInteger wa_networkActivityCount;

- (void)wa_pushNetworkActivity;
- (void)wa_popNetworkActivity;
- (void)wa_resetNetworkActivity;

@end
