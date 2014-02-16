#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class CameraView;

@interface CameraController : NSObject <AVCaptureFileOutputRecordingDelegate>
@property (assign) BOOL recording;
- (id)initWithViewController:(UIViewController *)controller camearView:(CameraView *)cameraView;
- (void)setupObservers;
- (void)removeObservers;
@end