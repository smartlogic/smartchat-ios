#import <UIKit/UIKit.h>

@class HTTPClient;
@class YBHALResource;

@interface FindFriendsViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

- (id)initWithClient:(HTTPClient *)client resource:(YBHALResource *)resource;

@end
