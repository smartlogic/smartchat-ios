#import <Foundation/Foundation.h>

@class AVCaptureSession;

@interface CameraView : UIView

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *stillButton;

@end