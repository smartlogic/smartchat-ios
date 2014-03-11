#import "FriendsViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <HyperBek/HyperBek.h>

#import "HTTPClient.h"

#import "FriendsView.h"
#import "Friend.h"
#import "FriendCell.h"

#import "FindFriendsViewController.h"

#import "UIAlertView+NSError.h"

@interface FriendsViewController ()

@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) YBHALLink *uploadLink;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) FriendsView *view;
@property (nonatomic, strong) UIImage *image;

@end

@implementation FriendsViewController

- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource
{
    self = [self init];
    if(self){
        self.client = client;
        self.resource = resource;
        self.recipients = [@[] mutableCopy];
    }
    return self;
}

- (id)initWithHTTPClient:(HTTPClient *)client resource:(YBHALResource *)resource image:(UIImage *)image
{
    self = [self initWithHTTPClient:client resource:resource];
    if(self){
        self.uploadLink = [resource linkForRelation:@"http://smartchat.smartlogic.io/relations/media"];
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view.tableView registerClass:[FriendCell class] forCellReuseIdentifier:FriendCellIdentifier];
    self.view.tableView.dataSource = self;
    self.view.tableView.delegate = self;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;

//    [RACObserve(self.cameraController, image) subscribeNext:^(UIImage *image){
//        if(image){
//            FriendsViewController *friendsViewController = [[FriendsViewController alloc] initWithHTTPClient:weakSelf.client resource:weakSelf.resource image:image];
//            friendsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//            [weakSelf.navigationController pushViewController:friendsViewController animated:YES];
//        }
//    }];


    __weak FriendsViewController *weakSelf = self;
    [self.client friends:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/friends"]
                     success:^(YBHALResource *resource, NSArray *friends) {
                         weakSelf.items = friends;
                         [weakSelf.view.tableView reloadData];
                         weakSelf.resource = resource;
                     }
                     failure:^(AFHTTPRequestOperation *task, NSError *error) {
                         [[UIAlertView alertViewWithError:error] show];
                     }];

    ((FriendsView *)self.view).doneButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {

        [self.client upload:self.uploadLink
                 recipients:self.recipients
                       file:self.image
                    overlay:nil
                        ttl:10.0f
                    success:^(YBHALResource *resource) {
                        NSLog(@"success");
                    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                        NSLog(@"error");
                    }];

        return [RACSignal empty];
    }];

}

- (IBAction)addButtonPressed:(id)sender
{
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] initWithClient:self.client resource:self.resource];
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

- (void)loadView
{
    self.view = [[FriendsView alloc] initWithFrame:[UIScreen mainScreen].bounds doneButton:(self.image)];
}

- (IBAction)sendButtonPressed:(id)sender
{
    NSLog(@"sendButtonPressed");
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    Friend *friend = self.items[indexPath.row];
    [cell configure:friend selected:[self.recipients containsObject:@(friend.ID)]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = (FriendCell *)[tableView cellForRowAtIndexPath:indexPath];
    Friend *friend = self.items[indexPath.row];
    NSNumber *ID = @(friend.ID);

    if([self.recipients containsObject:ID]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:ID];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:ID];
    }
}

@end
