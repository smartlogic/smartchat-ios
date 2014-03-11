#import "ChatsView.h"

@implementation ChatsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews
{
    NSDictionary *views = @{
                            @"superview": self,
                            @"tableView": self.tableView
                            };


    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|"
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