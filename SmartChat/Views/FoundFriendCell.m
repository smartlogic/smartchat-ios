#import "FoundFriendCell.h"

#import <HyperBek/HyperBek.h>

@interface FoundFriendCell ()

@property (nonatomic, strong) YBHALLink *link;

@end

@implementation FoundFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *button  =  [UIButton buttonWithType:UIButtonTypeContactAdd];
        self.accessoryView = button;
        [button addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configure:(YBHALResource *)resource
{
    self.textLabel.text = [resource objectForKeyedSubscript:@"username"];
    self.link = [resource linkForRelation:@"smartchat:add-friend"];
}

- (IBAction)addButtonPressed:(id)sender
{

}

@end
