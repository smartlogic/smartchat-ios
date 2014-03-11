#import "Credentials.h"

@implementation Credentials

- (NSString *)description
{
    return [NSString stringWithFormat:@"Credentials %@ | %@ | %@", self.username, self.password, self.privateKey];
}

- (id)initWithUsername:(NSString *)username password:(NSString *)password privateKey:(NSString *)privateKey
{
    self = [self init];
    if(self){
        self.username = username;
        self.password = password;
        self.privateKey = privateKey;
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
