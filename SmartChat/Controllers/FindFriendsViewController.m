#import "FindFriendsViewController.h"

#import <HyperBek/HyperBek.h>
#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APContact.h>

#import "HTTPClient.h"
#import "FindFriendsView.h"
#import "UIAlertView+NSError.h"

@interface FindFriendsViewController ()

@property (nonatomic, strong) HTTPClient *client;
@property (nonatomic, strong) YBHALResource *resource;
@end

@implementation FindFriendsViewController

- (id)initWithClient:(HTTPClient *)client resource:(YBHALResource *)resource
{
    self = [self init];
    if(self){
        self.client = client;
        self.resource = resource;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
                    NSLog(@"matches: %@", matches);
                }
                failure:^(AFHTTPRequestOperation *task, NSError *error) {
                    NSLog(@"error: %@", error);
                }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

}



@end