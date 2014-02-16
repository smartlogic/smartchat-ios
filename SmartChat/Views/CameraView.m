#import "CameraView.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraView ()

@end

@implementation CameraView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cameraButton = [[UIButton alloc] init];
        self.recordButton = [[UIButton alloc] init];
        self.stillButton = [[UIButton alloc] init];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.cameraButton setTitle:@"Cam" forState:UIControlStateNormal];
    self.cameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraButton.adjustsImageWhenHighlighted = YES;
    self.cameraButton.adjustsImageWhenDisabled = YES;

    [self.recordButton setTitle:@"Rec" forState:UIControlStateNormal];
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordButton.adjustsImageWhenHighlighted = YES;
    self.recordButton.adjustsImageWhenDisabled = YES;

    [self.stillButton setTitle:@"Still" forState:UIControlStateNormal];
    self.stillButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.stillButton.adjustsImageWhenHighlighted = YES;
    self.stillButton.adjustsImageWhenDisabled = YES;

    self.cameraButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    self.recordButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    self.stillButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];

    [self addSubview:self.cameraButton];
    [self addSubview:self.recordButton];
    [self addSubview:self.stillButton];

    NSDictionary *views = @{
            @"superview": self,
            @"cameraButton": self.cameraButton,
            @"recordButton": self.recordButton,
            @"stillButton": self.stillButton
    };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[stillButton(44)]-|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[recordButton(44)]-|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cameraButton(44)]-|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[stillButton(>=80)]-[recordButton(>=80)]-[cameraButton(>=80)]-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:views]];
    [super layoutSubviews];
}

- (AVCaptureSession *)session
{
	return ((AVCaptureVideoPreviewLayer *)self.layer).session;
}

- (void)setSession:(AVCaptureSession *)session
{
	((AVCaptureVideoPreviewLayer *)self.layer).session = session;
}

@end