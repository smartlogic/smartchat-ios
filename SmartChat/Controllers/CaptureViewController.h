#import <UIKit/UIKit.h>

@class HTTPClient;
@class YBHALResource;

@interface CaptureViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource;

@end
