#import <Foundation/Foundation.h>

@interface Credentials : NSObject

@property (nonatomic, strong, readonly) NSString *privateKey;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *password;
@property (readonly) BOOL authenticated;

- (id)initWithUserDefaults:(NSUserDefaults *)defaults;
- (id)initWithUsername:(NSString *)username password:(NSString *)password privateKey:(NSString *)privateKey;

@end
