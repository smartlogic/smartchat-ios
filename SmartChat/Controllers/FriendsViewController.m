#import "FriendsViewController.h"

#import <HyperBek/HyperBek.h>

#import "HTTPClient.h"

@interface FriendsViewController ()
@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableArray *selectedFriends;

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

    CGRect frame = CGRectMake(0, 64, 320, 640);
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.view addSubview:self.tableView];

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    [self.view addSubview:toolbar];

    self.sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendButtonPressed:)];
    toolbar.items = @[self.sendButton];

    __weak FriendsViewController *weakSelf = self;
    [self.client friends:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/friends"]
                 success:^(YBHALResource *resource, NSArray *friends) {
                     NSLog(@"friends, %@", friends);
                     NSLog(@"success");
                     weakSelf.items = friends;
                     [weakSelf.tableView reloadData];
                 } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                     NSLog(@"flailure");
                 }];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (IBAction)sendButtonPressed:(id)sender
{
    NSLog(@"sendButtonPressed");
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
    cell.textLabel.text = self.items[indexPath.row][@"username"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self.recipients addObject:self.items[indexPath.row][@"id"]];
}

@end
