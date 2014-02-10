#import <UIKit/UIKit.h>

@class HTTPClient;

@interface LoginViewController : UIViewController
- (id)initWithClient:(HTTPClient *)client;
@end