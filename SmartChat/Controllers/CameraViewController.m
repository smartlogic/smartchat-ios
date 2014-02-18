#import "CameraViewController.h"

#import <HyperBek/HyperBek.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UIAlertView+NSError.h"
#import "CameraView.h"
#import "CameraController.h"
#import "HTTPClient.h"
#import "Credentials.h"
#import "LoginView.h"
#import "RegisterView.h"

#import "FriendsViewController.h"

@interface CameraViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) CameraView *cameraView;
@property (nonatomic, strong) CameraController *cameraController;
@property (nonatomic, strong) LoginView *loginView;
@property (nonatomic, strong) RegisterView *registerView;
@property (nonatomic, strong) NSArray *recipients;

- (void)authenticate;
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

    self.registerView = [[RegisterView alloc] initWithFrame:self.view.frame];
    [[self.loginView.registerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self.loginView removeFromView];
        [self.registerView presentInView:self.view];
    }];

    [[self.registerView.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self.registerView removeFromView];
        [self.loginView presentInView:self.view];
    }];

    [[self.registerView.submitButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self registerUser];
    }];

    __weak CameraViewController *weakSelf = self;
    [RACObserve(self.cameraController, image) subscribeNext:^(UIImage *image){
        if(image){
            FriendsViewController *friendsViewController = [[FriendsViewController alloc] initWithHTTPClient:weakSelf.client resource:weakSelf.resource];
            [self.navigationController presentViewController:friendsViewController animated:YES completion:nil];
            [[friendsViewController rac_signalForSelector:@selector(sendButtonPressed:)] subscribeNext:^(UIBarButtonItem *sendButton) {

                NSLog(@"RAC got sendButtonPressed");
                [self.client upload:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/media"]
                         recipients:friendsViewController.recipients
                               file:image
                            overlay:nil
                                ttl:10.0f
                            success:^(YBHALResource *resource) {
                            }
                            failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                NSLog(@"error: %@", error);
                            }];

            }];
        }
    }];

    [self.client getRootResource:^(YBHALResource *resource) {

        self.resource = resource;

        if (self.client.authenticated) {
            [self loadRootResource];
            NSLog(@"authenticated, loading root resource");
        } else {
            NSLog(@"not authenticated, showing login view");
            [self.loginView presentInView:self.view];
        }

    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"error: %@", error);
    }];

}

- (void)registerDeviceIfNecessary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:kDefaultsDeviceRegistered]){
        [self.client registerDevice:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/devices"]
                            success:^(YBHALResource *resource) {
                                [defaults setBool:YES forKey:kDefaultsDeviceRegistered];
                                [defaults synchronize];
                        }
                        failure:^(AFHTTPRequestOperation *task, NSError *error) {
                            NSLog(@"error: %@", error);
                        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"CameraViewController#didReceiveMemoryWarning");
}

- (void)loadRootResource
{
    __weak CameraViewController *weakSelf = self;
    [self.client getRootResource:^(YBHALResource *resource) {
        weakSelf.resource = resource;
        [weakSelf registerDeviceIfNecessary];
        if(weakSelf.loginView.alpha > 0){
            [weakSelf.loginView removeFromView];
        }
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        [[UIAlertView alertViewWithError:error] show];
        NSLog(@"error: %@", error);
    }];

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
                          [weakSelf.loginView removeFromView];

                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                          [defaults setObject:username forKey:kDefaultsUsername];
                          [defaults setObject:password forKey:kDefaultsPassword];
                          [defaults setObject:privateKey forKey:kDefaultsPrivateKey];
                          [defaults synchronize];

                          Credentials *credentials = [[Credentials alloc] initWithUserDefaults:defaults];
                          HTTPClient *client = [HTTPClient clientWithClient:weakSelf.client credentials:credentials];
                          weakSelf.client = client;

                          [weakSelf loadRootResource];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [[UIAlertView alertViewWithError:error] show];
                          NSLog(@"error: %@", error);
                      }];
}

- (void)registerUser
{
    NSString *username = self.registerView.username;
    NSString *password = self.registerView.password;
    NSString *email = self.registerView.email;

    __weak CameraViewController *weakSelf = self;
    [self.client registerUser:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/users"]
                     username:username
                     password:password
                        email:email
                      success:^(YBHALResource *resource, NSString *privateKey){
                          [weakSelf.registerView removeFromView];

                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                          [defaults setObject:username forKey:kDefaultsUsername];
                          [defaults setObject:password forKey:kDefaultsPassword];
                          [defaults setObject:privateKey forKey:kDefaultsPrivateKey];
                          [defaults synchronize];

                          Credentials *credentials = [[Credentials alloc] initWithUserDefaults:defaults];
                          HTTPClient *client = [HTTPClient clientWithClient:weakSelf.client credentials:credentials];
                          weakSelf.client = client;
                          [weakSelf loadRootResource];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [[UIAlertView alertViewWithError:error] show];
                          NSLog(@"error: %@", error);
                      }];
}

@end