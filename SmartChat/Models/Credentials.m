#import "Credentials.h"

@implementation Credentials


- (id)initWithUsername:(NSString *)username password:(NSString *)password privateKey:(NSString *)privateKey
{
    self = [self init];
    if(self){
        _username = username;
        _password = password;
        _privateKey = privateKey;
    }
    
    return self;
}

- (id)initWithUserDefaults:(NSUserDefaults *)defaults
{
    return [self initWithUsername:[defaults stringForKey:kDefaultsUsername]
                         password:[defaults stringForKey:kDefaultsPassword]
                       privateKey:[defaults stringForKey:kDefaultsPrivateKey]];
}

- (BOOL)authenticated
{
    return (self.username && self.password && self.privateKey);
}

@end
