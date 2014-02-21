#import "Friend.h"

@interface Friend ()
@end

@implementation Friend

- (id)initWithUsername:(NSString *)username id:(NSInteger)ID
{
    self = [self init];
    if(self){
        self.username = username;
        self.ID = ID;
    }
    return self;
}

@end
