#import "FriendsView.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface FriendsView ()
@property (assign) BOOL showDoneButton;
@property (nonatomic, strong) UIToolbar *bottomToolbar;
@end

@implementation FriendsView

- (id)initWithFrame:(CGRect)frame doneButton:(BOOL)doneButton
{
    self = [self initWithFrame:frame];
    if(self){
        self.showDoneButton = doneButton;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[UITableView alloc] init];
        self.bottomToolbar = [[UIToolbar alloc] init];
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];

        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomToolbar.translatesAutoresizingMaskIntoConstraints = NO;

        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.bottomToolbar.items = @[flexibleSpace, self.self.doneButton];

        self.backgroundColor = [UIColor whiteColor];

        [self addSubview:self.tableView];
        [self addSubview:self.bottomToolbar];
    }
    return self;
}

- (void)layoutSubviews
{

    NSDictionary *views = @{
                            @"superview": self,
                            @"tableView": self.tableView,
                            @"bottomToolbar": self.bottomToolbar
                            };

    if(self.showDoneButton){

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][bottomToolbar(44)]|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[bottomToolbar]|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:views]];

    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:views]];
    }

    [super layoutSubviews];

}

@end
