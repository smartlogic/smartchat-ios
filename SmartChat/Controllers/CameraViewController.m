#import "CameraViewController.h"

#import <HyperBek/HyperBek.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "AuthenticationViewController.h"
#import "CameraController.h"
#import "CameraView.h"
#import "Credentials.h"
#import "FriendsViewController.h"
#import "ChatsViewController.h"
#import "HTTPClient.h"
#import "LoginView.h"
#import "RegisterView.h"

#import "UIAlertView+NSError.h"

@interface CameraViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) CameraView *cameraView;
@property (nonatomic, strong) CameraController *cameraController;
@property (nonatomic, strong) LoginView *loginView;
@property (nonatomic, strong) RegisterView *registerView;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) id observer;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)dealloc
{
    if(self.observer){
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cameraController = [[CameraController alloc] initWithViewController:self camearView:self.cameraView];
    [self.cameraController setupObservers];

    __weak CameraViewController *weakSelf = self;
    [RACObserve(self.cameraController, image) subscribeNext:^(UIImage *image){
        if(image){
            FriendsViewController *friendsViewController = [[FriendsViewController alloc] initWithHTTPClient:weakSelf.client resource:weakSelf.resource image:image];
            friendsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [weakSelf.navigationController pushViewController:friendsViewController animated:YES];
        }
    }];

    [self.client getRootResource:^(YBHALResource *resource) {

        self.resource = resource;

        if (self.client.authenticated) {
            [self loadRootResource];
        } else {
            AuthenticationViewController *authenticationViewController = [[AuthenticationViewController alloc] initWithClient:self.client resource:resource];
            [self.navigationController presentViewController:authenticationViewController animated:YES completion:nil];
        }

    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"getRooTesource failed: %@", error);
    }];

    CGRect bounds = [UIScreen mainScreen].bounds;

    UIButton *friendsButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width - 64, bounds.size.height - 64, 44, 44)];
    [friendsButton setTitle:@"≡" forState:UIControlStateNormal];
    friendsButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0f];
    [friendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cameraView addSubview:friendsButton];
    [friendsButton addTarget:self action:@selector(friendsViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *chatsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, bounds.size.height - 64, 44, 44)];
    [chatsButton setTitle:@"≡" forState:UIControlStateNormal];
    chatsButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0f];
    [chatsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cameraView addSubview:chatsButton];
    [chatsButton addTarget:self action:@selector(chatsViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

}

- (IBAction)friendsViewButtonPressed:(id)sender
{
    FriendsViewController *friendsViewController = [[FriendsViewController alloc] initWithHTTPClient:self.client resource:self.resource];
    [self.navigationController pushViewController:friendsViewController animated:YES];
}

- (IBAction)chatsViewButtonPressed:(id)sender
{
    ChatsViewController *chatsViewController = [[ChatsViewController alloc] initWithClient:self.client resource:self.resource];
    [self.navigationController pushViewController:chatsViewController animated:YES];
    
}

- (void)registerDeviceIfNecessary
{
    // Register device for APN
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"didRegisterForRemoteNotificationsWithDeviceToken" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.client registerDevice:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/devices"]
                             device:note.userInfo[@"deviceToken"]
                            success:^(YBHALResource *resource) {
                                // No-op
                            }
                            failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                NSLog(@"error: %@", error);
                            }];
    }];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"CameraViewController#didReceiveMemoryWarning");
}

- (void)loadRootResource:(YBHALResource *)resource
{
    self.resource = resource;
    [self loadRootResource];
}

- (void)loadRootResource
{
    __weak CameraViewController *weakSelf = self;
    [self.client getRootResource:^(YBHALResource *resource) {
        weakSelf.resource = resource;
        [weakSelf registerDeviceIfNecessary];
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        [[UIAlertView alertViewWithError:error] show];
        NSLog(@"error: %@", error);
    }];

}


@end