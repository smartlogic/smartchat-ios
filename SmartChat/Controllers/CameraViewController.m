#import "CameraViewController.h"

#import <HyperBek/HyperBek.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UIAlertView+NSError.h"
#import "CameraView.h"
#import "CameraController.h"
#import "HTTPClient.h"
#import "Credentials.h"
#import "LoginView.h"

@interface CameraViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) CameraView *cameraView;
@property (nonatomic, strong) CameraController *cameraController;
@property (nonatomic, strong) LoginView *loginView;
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

    self.loginView = [[LoginView alloc] initWithFrame:self.view.frame];
    [[self.loginView.submitButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self authenticate];
    }];


    [RACObserve(self.cameraController, image) subscribeNext:^(UIImage *image){
        if(image){
            [self.client upload:self.resource[@""]
                     recipients:@[@1]
                           file:image
                        overlay:nil
                            ttl:10.0f
                        success:^(YBHALResource *resource) {
                        }
                        failure:^(AFHTTPRequestOperation *task, NSError *error) {
                            NSLog(@"error: %@", error);
                        }];
        }
    }];

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
                self.loginView.alpha = 0;
                [UIView animateWithDuration:0.5f
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     [self.view addSubview:self.loginView];
                                     self.loginView.alpha = 1.0f;
                                 } completion:^(BOOL finished) {
                                     NSLog(@"completed");
                                 }];
                
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

- (void)authenticate
{
    NSString *username = self.loginView.username;
    NSString *password = self.loginView.password;

    __weak CameraViewController *weakSelf = self;
    [self.client authenticate:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/user-sign-in"]
                     username:username
                     password:password
                      success:^(YBHALResource *resource, NSString *privateKey){

                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                          [defaults setObject:username forKey:@"username"];
                          [defaults setObject:password forKey:@"password"];
                          [defaults setObject:privateKey forKey:@"privateKey"];
                          [defaults synchronize];

                          Credentials *credentials = [[Credentials alloc] initWithUserDefaults:defaults];
                          HTTPClient *client = [HTTPClient clientWithClient:self.client credentials:credentials];
                          CameraViewController *strongSelf = weakSelf;
                          strongSelf.client = client;

                          [client getRootResource:^(YBHALResource *resource) {
                              strongSelf.resource = resource;
                              [UIView animateWithDuration:0.5f
                                                    delay:0
                                                  options:UIViewAnimationOptionCurveEaseIn
                                               animations:^{
                                                   self.loginView.alpha = 0.0f;
                                               } completion:^(BOOL finished) {
                                                   if(finished){
                                                       [self.loginView removeFromSuperview];
                                                   }
                                               }];
                          } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                              [[UIAlertView alertViewWithError:error] show];
                              NSLog(@"error: %@", error);
                          }];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [[UIAlertView alertViewWithError:error] show];
                          NSLog(@"error: %@", error);
                      }];
}

@end