#import <Foundation/Foundation.h>

@interface NSString (KeySigning)

- (NSString *)signWithPrivateKey:(NSData *)privateKeyData passphrase:(NSString *)passphrase;

@end
