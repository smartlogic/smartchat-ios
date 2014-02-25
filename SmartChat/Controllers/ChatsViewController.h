#import <UIKit/UIKit.h>

@class HTTPClient;
@class YBHALResource;

@interface ChatsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithClient:(HTTPClient *)client resource:(YBHALResource *)resource;

@end
