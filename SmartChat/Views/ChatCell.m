#import "ChatCell.h"

#import <HyperBek/HyperBek.h>

#import "HTTPClient.h"

#import "UIAlertView+NSError.h"

NSString *const ChatCellIdentifier = @"ChatCellIdentifier";

@interface ChatCell ()

@property (nonatomic, strong) HTTPClient *client;
@end

@implementation ChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return self;
}

- (void)configure:(YBHALResource *)resource client:(HTTPClient *)client
{
    YBHALResource *creator = [resource resourceForRelation:@"creator"];
    self.textLabel.text  = [creator objectForKeyedSubscript:@"username"];
    self.links = [resource linksForRelation:@"http://smartchat.smartlogic.io/relations/files"];
    self.client = client;
}

- (void)startActivityIndicator
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView startAnimating];
    self.accessoryView = activityIndicatorView;
}

- (void)stopActivityIndicator
{
    [(UIActivityIndicatorView *)self.accessoryView stopAnimating];
}

- (void)disable
{
    self.textLabel.textColor = [UIColor grayColor];
}

@end
