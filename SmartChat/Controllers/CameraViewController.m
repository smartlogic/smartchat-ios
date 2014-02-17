#import "CameraViewController.h"

#import <HyperBek/HyperBek.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CameraView.h"
#import "CameraController.h"
#import "HTTPClient.h"
#import "LoginViewController.h"

@interface CameraViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) CameraView *cameraView;
@property (nonatomic, strong) CameraController *cameraController;
@end

@implementation CameraViewController

- (BOOL)shouldAutorotate
{
    return !self.cameraController.recording;
}

- (id)initWithHTTPClient:(HTTPClient *)client
{
    self = [self init];
    if(self){
        self.client = client;
    }
    return self;
}

- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource
{
    self = [self init];
    if(self){
        self.client = client;
        self.resource = resource;
    }
    return self;
}

- (void)loadView
{
    self.cameraView = [[CameraView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = self.cameraView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cameraController = [[CameraController alloc] initWithViewController:self camearView:self.cameraView];
    [self.cameraController setupObservers];


    if(self.resource){
        // NOTE: Guard with defaults check to see if the device has been registered already
        [self.client registerDevice:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/devices"]
                            success:^(YBHALResource *resource) {
                                NSLog(@"resource; %@", resource);
                            }
                            failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                NSLog(@"error: %@", error);
                            }];
    } else {
        [self.client getRootResource:^(YBHALResource *resource) {
            self.resource = resource;
            if (!self.client.authenticated) {
                LoginViewController *loginViewController = [[LoginViewController alloc] initWithClient:self.client];
                loginViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.navigationController presentViewController:loginViewController animated:YES completion:nil];
            }
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            NSLog(@"error: %@", error);
        }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"CameraViewController#didReceiveMemoryWarning");
}



@end