#import <UIKit/UIKit.h>

@class HTTPClient;
@class YBHALResource;

@interface AuthenticationViewController : UIViewController

- (id)initWithClient:(HTTPClient *)client resource:(YBHALResource *)resource;

@end
