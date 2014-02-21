#import <UIKit/UIKit.h>

@class YBHALResource;
@class HTTPClient;

extern NSString *const FoundFriendCellIdentifier;

@interface FoundFriendCell : UITableViewCell

- (void)configure:(YBHALResource *)resource client:(HTTPClient *)client;

@end
