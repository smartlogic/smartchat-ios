#import "FoundFriendCell.h"

#import <HyperBek/HyperBek.h>

#import "HTTPClient.h"

#import "UIAlertView+NSError.h"

NSString *const FoundFriendCellIdentifier = @"FoundFriendCellIdentifier";

@interface FoundFriendCell ()

@property (nonatomic, strong) YBHALLink *link;
@property (nonatomic, strong) HTTPClient *client;

@end

@implementation FoundFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *button  =  [UIButton buttonWithType:UIButtonTypeContactAdd];
        self.accessoryView = button;
        [button addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)configure:(YBHALResource *)resource client:(HTTPClient *)client
{
    self.textLabel.text = [resource objectForKeyedSubscript:@"username"];
    self.link = [resource linkForRelation:@"smartchat:add-friend"];
    self.client = client;
}

- (IBAction)addButtonPressed:(id)sender
{
    __weak FoundFriendCell *weakSelf = self;
    [self.client addFriend:self.link
                   success:^(YBHALResource *resource) {
                       DDLogVerbose(@"Friend added: %@", weakSelf.textLabel.text);
                   }
                   failure:^(AFHTTPRequestOperation *task, NSError *error) {
                       [UIAlertView alertViewWithError:error];
                   }];
}

@end
