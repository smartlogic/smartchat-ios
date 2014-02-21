#import <Foundation/Foundation.h>

@interface Credentials : NSObject

@property (nonatomic, strong) NSString *privateKey;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (readonly) BOOL authenticated;

- (id)initWithUserDefaults:(NSUserDefaults *)defaults;
- (id)initWithUsername:(NSString *)username password:(NSString *)password privateKey:(NSString *)privateKey;

@end
