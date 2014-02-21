#import "FriendCell.h"

#import "Friend.h"

NSString *const FriendCellIdentifier = @"FriendCellIdentifier";

@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)configure:(Friend *)friend selected:(BOOL)selected
{
    self.textLabel.text = friend.username;
    self.accessoryType = (selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
}

@end
