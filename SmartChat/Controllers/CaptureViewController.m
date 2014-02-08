#import "CaptureViewController.h"
#import <HyperBek/HyperBek.h>
#import <AVFoundation/AVFoundation.h>

#import "HTTPClient.h"

@interface CaptureViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) UIImagePickerController *imagePickerViewController;
@end

@implementation CaptureViewController

- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource
{
    self = [self init];
    if(self){
        self.client = client;
        self.resource = resource;
        self.imagePickerViewController = [[UIImagePickerController alloc] init];
        self.imagePickerViewController.delegate = self;
        self.imagePickerViewController.allowsEditing = YES;
        self.imagePickerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

        if(!input) {
            self.imagePickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            self.imagePickerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController presentViewController:self.imagePickerViewController animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"CameraViewController#didReceiveMemoryWarning");
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(CaptureViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    CGRect frame = CGRectMake(0, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44.0 - 44.0);
    self.imageView.frame = frame;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(CaptureViewController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end