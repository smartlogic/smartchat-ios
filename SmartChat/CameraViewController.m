#import "CameraViewController.h"
#import "HTTPClient.h"
#import "ImagePickerDelegate.h"

@interface CameraViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) ImagePickerDelegate *imagePickerDelegate;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation CameraViewController

- (id)initWithHTTPClient:(HTTPClient *)client
{
    self = [self init];
    if(self){
        self.client = client;
        self.imagePickerDelegate = [[ImagePickerDelegate alloc] init];
        self.delegate = self.imagePickerDelegate;
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

@end