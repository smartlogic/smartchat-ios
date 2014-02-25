#import <UIKit/UIKit.h>

@class YBHALResource;
@class HTTPClient;

extern NSString *const ChatCellIdentifier;

@interface ChatCell : UITableViewCell

- (void)configure:(YBHALResource *)resource client:(HTTPClient *)client;
- (IBAction)detailsButtonPressed:(id)sender;

@end
