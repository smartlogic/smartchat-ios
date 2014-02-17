#import <UIKit/UIKit.h>

@interface LoginView : UIView
@property (readonly) NSString *username;
@property (readonly) NSString *password;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *registerButton;

- (void)presentInView:(UIView *)view;
- (void)removeFromView;
@end