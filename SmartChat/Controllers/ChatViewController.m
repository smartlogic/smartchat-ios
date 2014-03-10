#import "ChatViewController.h"

@interface ChatViewController ()
@property (nonatomic, strong) UIImage *image;
@end

@implementation ChatViewController

- (id)initWithImage:(UIImage *)image
{
    self = [self init];
    if(self){
        self.image = image;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"self.image: %@", self.image);
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image = self.image;
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
