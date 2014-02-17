#import <UIKit/UIKit.h>

@class HTTPClient;
@class YBHALResource;

@interface CameraViewController : UIViewController

- (id)initWithHTTPClient:(HTTPClient *)client;
- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource;

@end
