#import <Kiwi/Kiwi.h>
#import "HTTPClient.h"

#import "Credentials.h"


SPEC_BEGIN(HTTPClientSpec)

describe(@"HTTPClient", ^{
    
    it(@"signs URLs", ^{
        Credentials *credentials = [[Credentials alloc] initWithUsername:@"example" password:@"password"];
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"private_key" ofType:@"pem"];
        credentials.privateKey = [NSString stringWithContentsOfFile:path
                                                           encoding:NSUTF8StringEncoding
                                                              error:NULL];
        HTTPClient *client = [[HTTPClient alloc] initWithCredentials:credentials];
        NSString *expected = @""
        "KZ7D/5A0M0EUcNvULw3irkU8aTIdeOKE12aDEaXPxelishdlkIKd9U/D8tbCuPfX"
        "dZvXxhcV8JHFLKOF0k2OLG05sIO5bRN7RDhkTadTtuSxyuIK5RvZhHTE2VVjCWyP"
        "0rvpag/CckCbhlI76V79zU/ZQhpu1xklBtEhaoqWB4zTFa2LhWz4b8/wV0OJ3fW1"
        "soqquCN26FSu019zeghoquTXEbmVfXvQdyio9wTAFYx9zjDI/qTCkvqr9pK4xo5P"
        "72atlkmYSNNL72uoYzat1V2+FMcy34HzLRL6wNMAWZtXvb8rXuVMTOCUjb0VwxNI"
        "JoIZHP+3HCijqn6QNNl6PA==";

        NSString *result = [client signedPath:@"http://example.org/example"];
        [[result should] equal:expected];
    });
});

SPEC_END
