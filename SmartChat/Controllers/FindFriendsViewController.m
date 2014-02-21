#import "FindFriendsViewController.h"

#import <HyperBek/HyperBek.h>
#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>

#import "HTTPClient.h"
#import "FindFriendsView.h"
#import "UIAlertView+NSError.h"

#import "FoundFriendCell.h"

@interface FindFriendsViewController ()

@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) NSArray *items;

@end

@implementation FindFriendsViewController

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

    [((FindFriendsView *)self.view).tableView registerClass:[FoundFriendCell class] forCellReuseIdentifier:FoundFriendCellIdentifier];

    ((FindFriendsView *)self.view).tableView.dataSource = self;
    ((FindFriendsView *)self.view).tableView.delegate = self;

    ((FindFriendsView *)self.view).searchBar.delegate = self;
    [((FindFriendsView *)self.view).searchBar becomeFirstResponder];

    APAddressBook *addressBook = [APAddressBook new];
    addressBook.fieldsMask = (APContactFieldEmails | APContactFieldPhones | APContactFieldFirstName | APContactFieldLastName);

    NSMutableArray *emails = [@[] mutableCopy];
    NSMutableArray *phones = [@[] mutableCopy];

    [addressBook loadContacts:^(NSArray *contacts, NSError *error) {
        if(error){
            [[UIAlertView alertViewWithError:error] show];
        } else {
            for (APContact *contact in contacts) {
                [emails addObjectsFromArray:contact.emails];
                [phones addObjectsFromArray:contact.phones];
            }

        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    self.view = [FindFriendsView new];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.client search:[self.resource linkForRelation:@"search"]
                 emails:@[searchBar.text]
                 phones:@[searchBar.text]
                success:^(YBHALResource *resource, NSArray *matches) {
                    self.items = matches;
                    [((FindFriendsView *)self.view).tableView reloadData];
                }
                failure:^(AFHTTPRequestOperation *task, NSError *error) {
                    [[UIAlertView alertViewWithError:error] show];
                }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoundFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:FoundFriendCellIdentifier];
    [cell configure:self.items[indexPath.row] client:self.client];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

@end