#import <UIKit/UIKit.h>

@class YBHALResource;

extern NSString *const FoundFriendCellIdentifier;

@interface FoundFriendCell : UITableViewCell

- (void)configure:(YBHALResource *)resource;

@end
