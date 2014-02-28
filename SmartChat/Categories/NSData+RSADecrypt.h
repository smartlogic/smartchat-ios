#import <Foundation/Foundation.h>

@interface NSData (RSADecrypt)

- (NSData *)decryptRSA:(NSString *)privateKeyData password:(NSString *)password;

@end
