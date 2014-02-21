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
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) FriendsView *view;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view.tableView registerClass:[FriendCell class] forCellReuseIdentifier:FriendCellIdentifier];
    self.view.tableView.dataSource = self;
    self.view.tableView.delegate = self;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;

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
        NSLog(@"doneButtonPressed");
        return [RACSignal empty];
    }];

}

- (IBAction)doneButtonPressed:(id)sender
{
    FindFriendsViewController *findFriendsViewController = [[FindFriendsViewController alloc] initWithClient:self.client resource:self.resource];
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

- (void)loadView
{
    self.view = [[FriendsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
