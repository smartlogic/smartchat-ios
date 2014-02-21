#import <UIKit/UIKit.h>

@class HTTPClient;
@class YBHALResource;

@interface CameraViewController : UIViewController

- (id)initWithHTTPClient:(HTTPClient *)client;
- (void)loadRootResource:(YBHALResource *)resource;

@end
