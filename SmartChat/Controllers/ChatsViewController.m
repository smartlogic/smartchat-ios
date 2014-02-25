#import "ChatsViewController.h"

#import <HyperBek/HyperBek.h>

#import "HTTPClient.h"
#import "ChatsView.h"
#import "ChatCell.h"


@interface ChatsViewController ()

@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation ChatsViewController

- (id)initWithClient:(HTTPClient *)client resource:(YBHALResource *)resource
{
    self = [self init];
    if(self){
        self.client = client;
        self.resource = resource;
        self.items = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self.chatsView.tableView registerClass:[ChatCell class] forCellReuseIdentifier:ChatCellIdentifier];
    self.chatsView.tableView.delegate = self;
    self.chatsView.tableView.dataSource = self;

    [self.client media:[self.resource linkForRelation:@"http://smartchat.smartlogic.io/relations/media"]
               success:^(YBHALResource *resource, NSArray *chats) {
                   self.items = chats;
                   [self.chatsView.tableView reloadData];
               } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                   NSLog(@"failure");
               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ChatsView *)chatsView
{
    return (ChatsView *)self.view;
}

- (void)loadView
{
    self.view = [[ChatsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatCellIdentifier];
    [cell configure:self.items[indexPath.row] client:self.client];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = (ChatCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell detailsButtonPressed:nil];
}

@end
