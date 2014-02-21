#import <UIKit/UIKit.h>

@class Friend;

extern NSString *const FriendCellIdentifier;

@interface FriendCell : UITableViewCell

- (void)configure:(Friend *)friend selected:(BOOL)selected;

@end
