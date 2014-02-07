#import "NSString+KeySigning.h"

#import <OpenSSL/des.h>
#import <OpenSSL/pem.h>
#import <OpenSSL/aes.h>
#import <OpenSSL/rsa.h>
#import <OpenSSL/err.h>

@implementation NSString (KeySigning)

- (NSString *)signWithPrivateKey:(NSData *)privateKeyData passphrase:(NSString *)passphrase;
{
    OPENSSL_add_all_algorithms_conf();
    BIO *publicBIO = NULL;
    EVP_PKEY *privateKey = NULL;
    
    const char *pass = [passphrase UTF8String];
    
    if ((publicBIO = BIO_new_mem_buf((unsigned char *)[privateKeyData bytes], [privateKeyData length])) == NO) {
        NSLog(@"BIO_new_mem_buf() failed!");
        return nil;
    }
    
    if (PEM_read_bio_PrivateKey(publicBIO, &privateKey, NULL, pass) == NO) {
        NSLog(@"PEM_read_bio_PrivateKey() failed!");
        return nil;
    }
    
    const char *cString = [self UTF8String];
    unsigned int stringLength = [self length];
    
    unsigned char *signatureBuffer[EVP_MAX_MD_SIZE];
    int signatureLength;
    
    EVP_MD_CTX msgDigestContext;
    const EVP_MD * msgDigest = EVP_sha256();
    
    EVP_MD_CTX_init(&msgDigestContext);
    EVP_SignInit(&msgDigestContext, msgDigest);
    EVP_SignUpdate(&msgDigestContext, cString, stringLength);
    
    if (EVP_SignFinal(&msgDigestContext, (unsigned char *)signatureBuffer, (unsigned int *)&signatureLength, privateKey) == NO) {
        NSLog(@"Failed to sign string.");
        return nil;
    }
    EVP_MD_CTX_cleanup(&msgDigestContext);
    EVP_PKEY_free(privateKey);
    
    NSData *signatureData = [NSData dataWithBytes:signatureBuffer length:signatureLength];
    NSString *signature = [signatureData base64EncodedStringWithOptions:0];
    
    return signature;
}

@end
