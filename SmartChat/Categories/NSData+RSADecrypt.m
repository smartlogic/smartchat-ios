#import "NSData+RSADecrypt.h"

#import <OpenSSL/des.h>
#import <OpenSSL/pem.h>
#import <OpenSSL/err.h>

@implementation NSData (RSADecrypt)

- (NSData *)decryptRSA:(NSString *)privateKeyData password:(NSString *)password
{
    // NOTE: This is called elsewhere (NSString Key Signing) whcih is potentially problematic.
    OpenSSL_add_all_algorithms();

    // For friendlier error reporting
    ERR_load_crypto_strings();
    ERR_load_ERR_strings();

    BIO *bio = BIO_new(BIO_s_mem());

    BIO_write(bio, [privateKeyData UTF8String], (int) strlen([privateKeyData UTF8String]));

    EVP_PKEY *pkey = EVP_PKEY_new();
    if(!PEM_read_bio_PrivateKey(bio, &pkey, 0, (char *)[password UTF8String])){
        ERR_print_errors_fp(stderr);
        BIO_free(bio);
        return nil;
    }

    BIO_free(bio);

    RSA *rsa = EVP_PKEY_get1_RSA(pkey);
    if(rsa == NULL){
        ERR_print_errors_fp(stderr);
        RSA_free(rsa);
        return nil;
    }

    unsigned long size = (sizeof (unsigned char)) * self.length;
    unsigned char *decrypt = malloc(size);

    int length = RSA_private_decrypt((int)self.length, (unsigned char *)self.bytes, decrypt, rsa, RSA_PKCS1_PADDING);
    if(-1 == length) {
        ERR_print_errors_fp(stderr);
        free(decrypt);
        RSA_free(rsa);
        return nil;
    }

    RSA_free(rsa);

    NSData *result = [NSData dataWithBytes:(const void *)decrypt length:length];
    free(decrypt);

    return result;
}

@end
