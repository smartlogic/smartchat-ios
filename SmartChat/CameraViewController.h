#import <UIKit/UIKit.h>

@class HTTPClient;
@class YBHALResource;

@interface CameraViewController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource;

@end
