#import "AuthenticationViewController.h"

#import <HyperBek/HyperBek.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "CameraViewController.h"
#import "Credentials.h"
#import "HTTPClient.h"
#import "LoginView.h"
#import "RegisterView.h"

#import "UIAlertView+NSError.h"

@interface AuthenticationViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) YBHALResource *resource;

@property (nonatomic, strong) LoginView *loginView;
@property (nonatomic, strong) RegisterView *registerView;
@end

@implementation AuthenticationViewController

- (id)initWithClient:(HTTPClient *)client resource:(YBHALResource *)resource
{
    self = [self init];
    if(self){
        self.client = client;
        self.resource = resource;
        self.loginView = [[LoginView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.registerView = [[RegisterView alloc]initWithFrame:[UIScreen mainScreen].bounds];;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.loginView];

    [[self.loginView.submitButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self authenticate];
    }];

    [[self.loginView.registerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [UIView transitionFromView:self.loginView
                            toView:self.registerView
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        completion:^(BOOL finished) { }];
    }];

    [[self.registerView.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [UIView transitionFromView:self.registerView
                            toView:self.loginView
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:nil];
    }];

    [[self.registerView.submitButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self registerUser];
    }];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)authenticate
{
    NSString *username = self.loginView.username;
    NSString *password = self.loginView.password;

    __weak AuthenticationViewController *weakSelf = self;
    [self.client authenticate:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/user-sign-in"]
                     username:username
                     password:password
                      success:^(YBHALResource *resource, NSString *privateKey){

                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                          [defaults setObject:username forKey:kDefaultsUsername];
                          [defaults setObject:password forKey:kDefaultsPassword];
                          [defaults setObject:privateKey forKey:kDefaultsPrivateKey];
                          [defaults synchronize];

                          weakSelf.resource = resource;

                          [self dismissViewControllerAnimated:YES completion:nil];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [[UIAlertView alertViewWithError:error] show];

                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                          [defaults removeObjectForKey:kDefaultsUsername];
                          [defaults removeObjectForKey:kDefaultsPassword];
                          [defaults removeObjectForKey:kDefaultsPrivateKey];
                          [defaults synchronize];

                          NSLog(@"error: %@", error);
                      }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    CameraViewController *cameraViewController = [self.presentingViewController childViewControllers][0];
    [cameraViewController loadRootResource:self.resource];

    [super viewWillDisappear:animated];
}

- (void)registerUser
{
    NSString *username = self.registerView.username;
    NSString *password = self.registerView.password;
    NSString *email = self.registerView.email;

    __weak AuthenticationViewController *weakSelf = self;
    [self.client registerUser:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/users"]
                     username:username
                     password:password
                        email:email
                      success:^(YBHALResource *resource, NSString *privateKey){

                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                          [defaults setObject:username forKey:kDefaultsUsername];
                          [defaults setObject:password forKey:kDefaultsPassword];
                          [defaults setObject:privateKey forKey:kDefaultsPrivateKey];
                          [defaults synchronize];

                          weakSelf.resource = resource;
                          [self dismissViewControllerAnimated:YES completion:nil];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [[UIAlertView alertViewWithError:error] show];
                          NSLog(@"error: %@", error);
                      }];
}


@end
