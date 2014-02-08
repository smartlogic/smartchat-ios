#import "Credentials.h"

@implementation Credentials

- (id)initWithUsername:(NSString *)username password:(NSString *)password
{
    self = [self init];
    if(self){
        self.username = username;
        self.password = password;
    }
    
    return self;
}

@end
