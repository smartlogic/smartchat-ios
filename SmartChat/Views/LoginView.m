#import "LoginView.h"

#import <ReactiveCocoa.h>

@interface LoginView ()
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@end

@implementation LoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.usernameField = [[UITextField alloc] init];
        self.usernameField.translatesAutoresizingMaskIntoConstraints = NO;
        self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.usernameField.borderStyle = UITextBorderStyleRoundedRect;
        self.usernameField.placeholder = @"Username";
        
        self.passwordField = [[UITextField alloc] init];
        self.passwordField.translatesAutoresizingMaskIntoConstraints = NO;
        self.passwordField.secureTextEntry = YES;
        self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
        self.passwordField.placeholder = @"Password";
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.submitButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.submitButton.backgroundColor = [UIColor colorWithRed:119/255.0f green:205/255.0f blue:117/255.0f alpha:1.0f];
        [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
        [self.submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.registerButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.registerButton.backgroundColor = [UIColor colorWithRed:150/255.0f green:150/255.0f blue:150/255.0f alpha:1.0f];
        [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
        [self.registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return self;
}

- (void)presentInView:(UIView *)view
{
    self.alpha = 0;
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [view addSubview:self];
                         self.alpha = 1.0f;
                     }
                     completion:nil];
}

- (void)removeFromView
{
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             [self removeFromSuperview];
                         }
                     }];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];

    NSDictionary *views = @{
                            @"superview": self,
                            @"usernameField": self.usernameField,
                            @"passwordField": self.passwordField,
                            @"submitButton": self.submitButton,
                            @"registerButton": self.registerButton
                            };

    [self addSubview:self.usernameField];
    [self addSubview:self.passwordField];
    [self addSubview:self.submitButton];
    [self addSubview:self.registerButton];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-88-[usernameField(31)]-[passwordField(31)]-[submitButton(44)]-[registerButton(44)]"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:views]];

    // Having this one view centered causes other X-aligned views to be centered.
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameField
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[passwordField(200)]"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[usernameField(200)]"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[submitButton(200)]"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[registerButton(200)]"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:views]];
    [super layoutSubviews];
}

#pragma mark - properties

- (NSString *)username
{
    return self.usernameField.text;
}

- (NSString *)password
{
    return self.passwordField.text;
}

@end
