#import <UIKit/UIKit.h>

@class HTTPClient; 
@interface CameraViewController : UIImagePickerController

- (id)initWithHTTPClient:(HTTPClient *)client;

@end
