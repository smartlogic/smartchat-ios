#import <Foundation/Foundation.h>

@interface Credentials : NSObject

@property (nonatomic, strong) NSString *privateKey;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

- (id)initWithUsername:(NSString *)username password:(NSString *)password;

@end
