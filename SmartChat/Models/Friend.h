#import <Foundation/Foundation.h>

@interface Friend : NSObject

@property (nonatomic, strong) NSString *username;
@property (assign) NSInteger ID;

- (id)initWithUsername:(NSString *)username id:(NSInteger)ID;

@end
