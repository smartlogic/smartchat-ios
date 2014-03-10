#import "ChatsView.h"

@implementation ChatsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.tableView = [[UITableView alloc] initWithFrame:frame];
    }
    return self;
}

- (void)layoutSubviews
{

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = @{
                            @"superview": self,
                            @"tableView": self.tableView
                            };

    self.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.tableView];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tableView]|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:views]];
    [super layoutSubviews];
}

@end