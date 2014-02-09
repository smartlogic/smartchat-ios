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
    return [self initWithUsername:[defaults stringForKey:@"username"]
                         password:[defaults stringForKey:@"password"]
                       privateKey:[defaults stringForKey:@"privateKey"]];
}

- (BOOL)authenticated
{
    return (self.username && self.password && self.privateKey);
}

@end
