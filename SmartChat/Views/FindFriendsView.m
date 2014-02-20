#import "FindFriendsView.h" 

@interface FindFriendsView ()
@end

@implementation FindFriendsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,70,320,44)];
        self.tableView = [[UITableView alloc] init];
    }
    return self;
}

- (void)layoutSubviews
{

    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;

    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = @{
                            @"superview": self,
                            @"tableView": self.tableView,
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
