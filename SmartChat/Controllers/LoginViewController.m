#import "LoginViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <HyperBek/HyperBek.h>

#import "Credentials.h"
#import "HTTPClient.h"

#import "CameraViewController.h"

@interface LoginViewController ()
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) YBHALResource *rootResource;
@property (nonatomic, strong) HTTPClient *client;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.client getRootResource:^(YBHALResource *resource) {
        self.rootResource = resource;
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"error: %@", error);
    }];

    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)configureView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 220, 40)];
    usernameLabel.text = @"Username";
    
    self.usernameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, 220, 40)];
    self.usernameField.borderStyle = UITextBorderStyleBezel;
    self.usernameField.text = @"tvon";
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 220, 40)];
    passwordLabel.text = @"Password";
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(10, 180, 220, 40)];
    self.passwordField.borderStyle = UITextBorderStyleBezel;
    self.passwordField.text = @"password";
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 220, 220, 40)];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 260, 220, 40)];
    [registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:usernameLabel];
    [self.view addSubview:self.usernameField];
    [self.view addSubview:passwordLabel];
    [self.view addSubview:self.passwordField];
    [self.view addSubview:submitButton];
    [self.view addSubview:registerButton];
}

- (IBAction)registerButtonPressed:(id)sender
{
    NSLog(@"registerButtonPressed");
}

- (IBAction)submitButtonPressed:(id)sender
{
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    Credentials *credentials = [[Credentials alloc] initWithUsername:username password:password];

    HTTPClient *client = [[HTTPClient alloc] initWithCredentials:credentials];
    [client authenticate:[self.rootResource linkForRelation:@"http://smartchat.smartlogic.io/relations/user-sign-in"]
                 success:^(YBHALResource *resource) {
                     [client getRootResource:^(YBHALResource *resource) {
                         CameraViewController *cameraViewController = [[CameraViewController alloc] initWithHTTPClient:client
                                                                                                              resource:resource];
                         [self.navigationController pushViewController:cameraViewController animated:YES];
                     } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                         NSLog(@"error: %@", error);
                     }];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"error: %@", error);
                 }];
}

@end
