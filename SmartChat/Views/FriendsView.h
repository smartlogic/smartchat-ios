#import <UIKit/UIKit.h>

@interface FriendsView : UIView

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (id)initWithFrame:(CGRect)frame doneButton:(BOOL)doneButton;

@end
