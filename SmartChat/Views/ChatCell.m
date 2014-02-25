#import "ChatCell.h"

#import <HyperBek/HyperBek.h>

#import "HTTPClient.h"

#import "UIAlertView+NSError.h"

NSString *const ChatCellIdentifier = @"ChatCellIdentifier";

@interface ChatCell ()

@property (nonatomic, strong) NSArray *links;
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

- (IBAction)detailsButtonPressed:(id)sender
{
    for (YBHALLink *link in self.links) {
        [self.client file:link
                  success:^(NSData *data) {
                      NSLog(@"results");
                  } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                      NSLog(@"error");
                  }];
    }
}



@end
