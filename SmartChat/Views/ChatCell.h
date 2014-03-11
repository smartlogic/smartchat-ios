#import <UIKit/UIKit.h>

@class YBHALResource;
@class HTTPClient;

extern NSString *const ChatCellIdentifier;

@interface ChatCell : UITableViewCell

@property (nonatomic, strong) NSArray *links;

- (void)configure:(YBHALResource *)resource client:(HTTPClient *)client;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)disable;

@end
