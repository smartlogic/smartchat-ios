#import "NSString+SHA256Digest.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (SHA256Digest)

- (NSString *)SHA256Digest
{
    const char *str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    
    return ret;
}

@end
