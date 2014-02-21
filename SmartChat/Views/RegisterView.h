#import <UIKit/UIKit.h>

@interface RegisterView : UIView

@property (readonly) NSString *username;
@property (readonly) NSString *password;
@property (readonly) NSString *email;

@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *signInButton;

@end
