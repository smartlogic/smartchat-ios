#import <Kiwi+KIF.h>

KIF_SPEC_BEGIN(AuthenticationSpec)

describe(@"Authentication", ^{

    __block NSString *username;
    __block NSString *email;

    beforeAll(^{
        username = [NSString stringWithFormat:@"user-%ld", (long)[[NSDate date] timeIntervalSince1970]];
        email = [NSString stringWithFormat:@"%@@example.com", username];
    });

    beforeEach(^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"username"];
        [defaults removeObjectForKey:@"password"];
        [defaults removeObjectForKey:@"privateKey"];
        [defaults synchronize];
    });

    it(@"should allow registration", ^{
        [tester waitForTappableViewWithAccessibilityLabel:@"Register"];
        [tester tapViewWithAccessibilityLabel:@"Register"];

        [tester waitForViewWithAccessibilityLabel:@"Email Address"];

        [tester enterText:email intoViewWithAccessibilityLabel:@"Email Address"];
        [tester enterText:username intoViewWithAccessibilityLabel:@"Username"];
        [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Password"];
        [tester enterText:@"password" intoViewWithAccessibilityLabel:@"Confirm Password"];

        [tester tapViewWithAccessibilityLabel:@"Submit"];
    });

    it(@"should allow authentication", ^{
        [tester waitForViewWithAccessibilityLabel:@"Username"];
        [tester waitForViewWithAccessibilityLabel:@"Password"];
        [tester waitForTappableViewWithAccessibilityLabel:@"Submit"];
        [tester waitForTappableViewWithAccessibilityLabel:@"Register"];

        [tester enterText:username intoViewWithAccessibilityLabel:@"Username"];
        [tester tapViewWithAccessibilityLabel:@"Submit"];
    });

});

KIF_SPEC_END