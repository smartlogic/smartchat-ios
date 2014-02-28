#import <Kiwi/Kiwi.h>

#import "NSData+RSADecrypt.h"

SPEC_BEGIN(NSDataRSADecryptSpec)

describe(@"NSData+RSADecrypt", ^{
    it(@"decrypts", ^{

        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"private_key" ofType:@"pem"];
        NSString *privateKeyString = [NSString stringWithContentsOfFile:path
                                                               encoding:NSUTF8StringEncoding
                                                                  error:NULL];

        // The string "encryption test" encrypted via ruby and base64 encoded.
        NSString *encryptedEncoded = @"i2v/7b4epps9S6r2DASDeGRTTgsYT6Apjx7TWHlj1atNbb07DpXpcD6ZZtA3BVGWdqsgcKZ708qQ1cg+ZUJxdqiZInO5sJxSBGAivU+KgzARRs3bv0yp5HKAxWqHKBpI9BEq5grjb00fSmw/poPHme8XBUq1nvWv58PgnNyxGdC1p+jO4s8DCbnPxPOyvGtK5L7jDK9IDtfV3H72mwXlRR0FB6ussLdnxJH9fbUNa24FUs5/tRTP1qsvNA6zuoq/CKyxzq35b1KVaqgkBU9uNZBeBMYE7gqW4G0Rgy0E9D1tGLziBQc6LmxOTuYoUlJGVyrXf1zsxgaFNLUUt000vg==";

        NSData *encrypted = [[NSData alloc] initWithBase64EncodedString:encryptedEncoded options:0];
        NSData *decrypted = [encrypted decryptRSA:privateKeyString password:@"727f38dc36b85a68d6bcdd7a7168e0ea3dda10c921117c8b796d7dec9dd1078c"];

        NSString *result = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
        [[result should] equal:@"encryption test"];
    });

});

SPEC_END
