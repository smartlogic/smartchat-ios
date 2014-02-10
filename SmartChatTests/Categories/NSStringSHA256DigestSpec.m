#import <Kiwi/Kiwi.h>
#import "NSString+SHA256Digest.h"

SPEC_BEGIN(NSStringSHA256DigestSpec)

describe(@"NSString+SHA256Digest", ^{
    
    it(@"creates a SHA256 digest of a string", ^{
        NSString *result = [@"password" SHA256Digest];
        NSString *expectation = @"5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8";
        [[result should] equal:expectation];
    });

});

SPEC_END
