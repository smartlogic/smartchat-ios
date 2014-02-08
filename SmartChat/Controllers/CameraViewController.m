#import "CameraViewController.h"
#import <HyperBek/HyperBek.h>
#import <AVFoundation/AVFoundation.h>

#import "HTTPClient.h"

@interface CameraViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YBHALResource *resource;
@end

@implementation CameraViewController

- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource
{
    self = [self init];
    if(self){
        self.client = client;
        self.resource = resource;
        self.delegate = self;
        self.allowsEditing = YES;

        AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

        if(!input) {
            NSLog(@"No camera available, using photo library");
            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"CameraViewController#didReceiveMemoryWarning");
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(CameraViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController:%@ didFinishPickingMediaWithInfo:%@", picker, info);
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"image: %@", image);
}

- (void)imagePickerControllerDidCancel:(CameraViewController *)picker
{
    NSLog(@"imagePickerControllerDidCancel:%@", picker);
}


@end