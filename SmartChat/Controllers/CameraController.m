#import "CameraController.h"

#import "CameraView.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

static void *CapturingStillImageContext = &CapturingStillImageContext;
static void *RecordingContext = &RecordingContext;
static void *SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CameraController ()

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) CameraView *cameraView;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;

@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;

@property (assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (assign) BOOL deviceAuthorized;

@property (nonatomic) id runtimeErrorHandlingObserver;

@property (nonatomic, weak) UIViewController *controller;

@end

@implementation CameraController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return self.captureSession.isRunning && self.deviceAuthorized;
}

- (void)setupObservers
{
    [self dispatchInSessionQueue:^{
        [RACObserve(self.captureStillImageOutput, capturingStillImage) subscribeNext:^(NSNumber *capturingStillImage){
            if([capturingStillImage boolValue]){
                NSLog(@"capturingStillImage observer is true");
                [self runStillImageCaptureAnimation];
            }
        }];
        [RACObserve(self, sessionRunningAndDeviceAuthorized) subscribeNext:^(NSNumber *sessionRunningAndDeviceAuthorized){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cameraView.cameraButton.enabled = [sessionRunningAndDeviceAuthorized boolValue];
                self.cameraView.recordButton.enabled = [sessionRunningAndDeviceAuthorized boolValue];
                self.cameraView.stillButton.enabled = [sessionRunningAndDeviceAuthorized boolValue];
            });
        }];

        [RACObserve(self.captureMovieFileOutput, recording) subscribeNext:^(NSNumber *recording){
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([recording boolValue]) {
                    self.cameraView.cameraButton.enabled = NO;
                    [self.cameraView.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
                    self.cameraView.recordButton.enabled = YES;
                } else {
                    self.cameraView.cameraButton.enabled = YES;
                    [self.cameraView.recordButton setTitle:@"Record" forState:UIControlStateNormal];
                    self.cameraView.recordButton.enabled = YES;
                }
            });

        }];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.captureDeviceInput.device];

        __weak CameraController *weakSelf = self;
        self.runtimeErrorHandlingObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:self.captureSession queue:nil usingBlock:^(NSNotification *note) {
            CameraController *strongSelf = weakSelf;
            dispatch_async(strongSelf.sessionQueue, ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [strongSelf.captureSession startRunning];
                [strongSelf.cameraView.recordButton setTitle:@"Rec" forState:UIControlStateNormal];
            });
        }];
        [self.captureSession startRunning];
    }];
}

 - (void)dispatchInSessionQueue:(void (^)())block
{
    dispatch_async(self.sessionQueue, ^{
        block();
    });
}
 - (void)removeObservers
{
     [self dispatchInSessionQueue:^{
         [self.captureSession stopRunning];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.captureDeviceInput.device];
         [[NSNotificationCenter defaultCenter] removeObserver:self.runtimeErrorHandlingObserver];
     }];
}

- (id)initWithViewController:(UIViewController *)controller camearView:(CameraView *)cameraView
{
    self = [self init];
    if(self){
        self.controller = controller;
        self.cameraView = cameraView;
        self.captureSession = [[AVCaptureSession alloc] init];
        self.cameraView.session = self.captureSession;
        [self setup];
    }

    return self;
}
- (id)initWithCameraView:(CameraView *)cameraView
{
    NSLog(@"CameraController#initWithCameraView");
    self = [self init];
    if(self){
        self.cameraView = cameraView;
        self.captureSession = [[AVCaptureSession alloc] init];
        self.cameraView.session = self.captureSession;
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSLog(@"CameraController#setup");
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;

	dispatch_async(sessionQueue, ^{

        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;

		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [CameraController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		
		if (error) {
			NSLog(@"%@", error);
		}
		
		if ([self.captureSession canAddInput:captureDeviceInput]) {
            NSLog(@"canAddInput:captureDeviceInput: %@", captureDeviceInput);
			[self.captureSession addInput:captureDeviceInput];
            self.captureDeviceInput = captureDeviceInput;

			dispatch_async(dispatch_get_main_queue(), ^{
				// Why are we dispatching this to the main queue?
				// Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can
                // only be manipulated on main thread.
				// Note: As an exception to the above rule, it is not necessary to serialize video orientation
                // changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.

                ((AVCaptureVideoPreviewLayer *)self.cameraView.layer).connection.videoOrientation = (AVCaptureVideoOrientation)self.controller.interfaceOrientation;
			});
		}
		
		AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
		AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		
		if (error) {
			NSLog(@"%@", error);
		}
		
		if ([self.captureSession canAddInput:audioDeviceInput]) {
			[self.captureSession addInput:audioDeviceInput];
		}
		
		self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		if ([self.captureSession canAddOutput:self.captureMovieFileOutput]) {
            NSLog(@"canAddOutput");
			[self.captureSession addOutput:self.captureMovieFileOutput];
			AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
			if ([connection isVideoStabilizationSupported]) {
                NSLog(@"isVideoStabilizationSupported(YES)");
				[connection setEnablesVideoStabilizationWhenAvailable:YES];
            }
		}
		
        self.captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
			[self.captureStillImageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
			[self.captureSession addOutput:self.captureStillImageOutput];
		}
	});

    [self.cameraView.stillButton addTarget:self action:@selector(snapStillImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.cameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraView.recordButton addTarget:self action:@selector(toggleMovieRecording:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExposeTap:)];
    [self.cameraView addGestureRecognizer:tapGestureRecognizer];

}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    NSLog(@"CameraController#setFlashMode");
	if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		} else {
			NSLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSLog(@"CameraController#deviceWithMediaType");
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];

	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			captureDevice = device;
			break;
		}
	}

	return captureDevice;
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"CameraController#captureOutput");
	if (error) {
		NSLog(@"%@", error);
    }

    self.recording = NO;

	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion
    // handler to end the background task associated with this recording. This
    // allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier,
    // once the movie file output's -isRecording is back to NO — which happens
    // sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;

	[[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
		if (error){
			NSLog(@"%@", error);
        }
		
		[[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
		
		if (backgroundRecordingID != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }
	}];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    NSLog(@"CameraController#subjectAreaDidChange");
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    [self dispatchInSessionQueue:^{
        AVCaptureDevice *device = self.captureDeviceInput.device;
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cameraView.layer.opacity = 0.0;
        [UIView animateWithDuration:.25 animations:^{
            self.cameraView.layer.opacity = 1.0;
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted) {
            self.deviceAuthorized = YES;
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"Authorization"
											message:@"SmartChat needs permisssion to use the Camera."
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
                self.deviceAuthorized = NO;
			});
		}
	}];
}

#pragma mark - Events

- (IBAction)toggleMovieRecording:(id)sender
{
    self.cameraView.recordButton.enabled = NO;

    dispatch_async([self sessionQueue], ^{
        if(!self.captureMovieFileOutput.isRecording)
        {
            self.recording = YES;

            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback
                // is not received until AVCam returns to the foreground unless you request background execution time. This also
                // ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude
                // this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after
                // the recorded file has been saved.
                self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }

            // Update the orientation on the movie file output video connection before starting recording.
            [[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:((AVCaptureVideoPreviewLayer *)self.cameraView.layer).connection.videoOrientation];

            // Turning OFF flash for video recording
            [CameraController setFlashMode:AVCaptureFlashModeOff forDevice:self.captureDeviceInput.device];

            // Start recording to a temporary file.
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            [self.captureMovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        } else {
            [self.captureMovieFileOutput stopRecording];
        }
    });
}

- (IBAction)changeCamera:(id)sender
{
    self.cameraView.cameraButton.enabled = NO;
    self.cameraView.recordButton.enabled = NO;
    self.cameraView.stillButton.enabled = NO;

    [self dispatchInSessionQueue:^{
        AVCaptureDevice *currentVideoDevice = self.captureDeviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];

        switch (currentPosition) {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }

        AVCaptureDevice *videoDevice = [CameraController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];

        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:[self captureDeviceInput]];

        if ([self.captureSession canAddInput:videoDeviceInput]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];

            [CameraController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];

            [self.captureSession addInput:videoDeviceInput];
            self.captureDeviceInput = videoDeviceInput;
        } else {
            [self.captureSession addInput:self.captureDeviceInput];
        }

        [self.captureSession commitConfiguration];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraView.cameraButton.enabled = YES;
            self.cameraView.recordButton.enabled = YES;
            self.cameraView.stillButton.enabled = YES;
        });
    }];
}

- (IBAction)snapStillImage:(id)sender
{
    [self dispatchInSessionQueue:^{
        // Update the orientation on the still image output video connection before capturing.
        [[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:((AVCaptureVideoPreviewLayer *)self.cameraView.layer).connection.videoOrientation];

        // Flash set to Auto for Still Capture
        [CameraController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self captureDeviceInput] device]];

        // Capture a still image.
        [[self captureStillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self captureStillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {

            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
//                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
        }];
    }];
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self cameraView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

@end
