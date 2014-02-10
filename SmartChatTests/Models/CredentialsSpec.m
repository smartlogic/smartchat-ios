#import <Kiwi/Kiwi.h>
#import "Credentials.h"

SPEC_BEGIN(CredentialsSpec)

describe(@"Credentials", ^{

    beforeEach(^{
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        [defaults removeObjectForKey:@"username"];
        [defaults removeObjectForKey:@"password"];
        [defaults removeObjectForKey:@"privateKey"];
    });

    it(@"can be initialized via NSUserDefaults", ^{
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        [defaults setObject:@"example username" forKey:@"username"];
        [defaults setObject:@"example password" forKey:@"password"];
        [defaults setObject:@"example privateKey" forKey:@"privateKey"];
        Credentials *credentials = [[Credentials alloc] initWithUserDefaults:defaults];

        [[credentials.username should] equal:@"example username"];
        [[credentials.password should] equal:@"example password"];
        [[credentials.privateKey should] equal:@"example privateKey"];
    });
    

    context(@"authenticated status", ^{

        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];

        beforeEach(^{
            [defaults setObject:@"example username" forKey:@"username"];
            [defaults setObject:@"example password" forKey:@"password"];
        });

        it(@"is not authenticated when authentication data does not exist", ^{
            Credentials *credentials = [[Credentials alloc] initWithUserDefaults:defaults];
            [[theValue(credentials.authenticated) should] equal:theValue(NO)];
        });
        
        it(@"is authenticated when authentication data exists", ^{
            [defaults setObject:@"example privateKey" forKey:@"privateKey"];
            Credentials *credentials = [[Credentials alloc] initWithUserDefaults:defaults];
            [[theValue(credentials.authenticated) should] equal:theValue(YES)];
        });

    });
});

SPEC_END
