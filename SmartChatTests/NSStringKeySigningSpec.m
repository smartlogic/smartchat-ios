#import <Kiwi/Kiwi.h>
#import "NSString+KeySigning.h"

SPEC_BEGIN(NSStringKeySigningSpec)

describe(@"NSString+KeySigning", ^{

    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"private_key" ofType:@"pem"];
    NSString *privateKeyString = [NSString stringWithContentsOfFile:path
                                                           encoding:NSUTF8StringEncoding
                                                              error:NULL];
    NSString *expected = @"fQjETWgIMqXEhNyJ52VdsZJIuXX+RHXO4wT5sFtMJBUMTpidksZ8NaQ3Fp1N\nYy2mJEee7Y835IOuFrGpkRroZWnO6s+jvTfWCmaK4DkRKVOB3DbS/o37+PA1\naGVHr7lKh0HHPk6tv7chxUbcdNKC+AWR5/m2DxehhAl23tdyDK2qPr0u2HLv\nzgHNnR4TQafjGOKVAekLdTLu0CUfd8fdzpUEJK5TdUkd6rA5zoORjsLOZXY/\n7cbanCzs2nNii9onJJov8SvbzLZ7e2Pq36Gum6AubZAEh0TMM7LRUQPDbogq\n69ZyXGD+eeuw9eZGkxiTd0ti3EFT9+OYpNnFRh/KAg==\n";
    
    NSString *result = [@"password" signWithPrivateKey:[privateKeyString dataUsingEncoding:NSUTF8StringEncoding]
                                            passphrase:@"727f38dc36b85a68d6bcdd7a7168e0ea3dda10c921117c8b796d7dec9dd1078c"];
    
    [[result should] equal:expected];
});

SPEC_END
