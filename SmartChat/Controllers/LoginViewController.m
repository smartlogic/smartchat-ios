#import "LoginViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <HyperBek/HyperBek.h>

#import "UIAlertView+NSError.h"

#import "Credentials.h"
#import "HTTPClient.h"

#import "CaptureViewController.h"

#import "LoginView.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LoginViewController ()
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) YBHALResource *rootResource;
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) LoginView *view;
@end

@implementation LoginViewController

- (id)initWithClient:(HTTPClient *)client
{
    self = [self init];
    if(self){
        self.client = client;
    }
    return self;
}

- (void)loadView
{
    self.view = [[LoginView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;

    [self getRootResource];

    [[self.view.submitButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [self authenticate];
    }];

}

- (void)getRootResource
{
    [self.client getRootResource:^(YBHALResource *resource) {
        self.rootResource = resource;
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"error: %@", error);
        [[UIAlertView alertViewWithError:error] show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)authenticate
{
    NSString *username = self.view.username;
    NSString *password = self.view.password;

    [self.client authenticate:[self.rootResource linkForRelation:@"http://smartchat.smartlogic.io/relations/user-sign-in"]
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

                          [client getRootResource:^(YBHALResource *resource) {
                              CaptureViewController *cameraViewController = [[CaptureViewController alloc] initWithHTTPClient:client
                                                                                                                     resource:resource];
                              [self.navigationController pushViewController:cameraViewController animated:YES];
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
