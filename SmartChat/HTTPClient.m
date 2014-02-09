#import "HTTPClient.h"
#import "Credentials.h"

#import "NSString+SHA256Digest.h"
#import "NSString+KeySigning.h"

#import <AFNetworking/AFNetworking.h>
#import <HyperBek/HyperBek.h>

@interface HTTPClient ()
@property (nonatomic, strong) Credentials *credentials;
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation HTTPClient

- (id)init
{
    self = [super init];
    if(self){
        self.baseURL = [NSURL URLWithString:@"http://roberto.local:9000/"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:(NSJSONWritingPrettyPrinted)];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager = manager;
    }
    
    return self;
}

- (id)initWithCredentials:(Credentials *)credentials
{
    self = [self init];
    if(self) {
        self.credentials = credentials;
    }
    
    return self;
}

- (void)getRootResource:(void (^)(YBHALResource *resource))success
                failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure
{
    if(self.credentials && self.credentials.username && self.credentials.password){
        NSString *signedPath = [self signedPath:self.baseURL.absoluteString];
        [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.credentials.username password:signedPath];
    }
    
    [self.manager GET:self.baseURL.absoluteString parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success([responseObject HALResourceWithBaseURL:self.baseURL]);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(operation, error);
              }];
}

- (void)authenticate:(YBHALLink *)link
             success:(void (^)(YBHALResource *))success
             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.credentials.username
                                                                   password:self.credentials.password];

    [self.manager POST:[link.URL absoluteString]
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   YBHALResource *resource = [responseObject HALResourceWithBaseURL:self.baseURL];
                   self.credentials.privateKey = [resource objectForKeyedSubscript:@"private_key"];
                   success(resource);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   failure(operation, error);
               }];
}

- (NSString *)passphrase
{
    NSString *passphrase = [self.credentials.password copy];
    NSString *input;

    for(int i = 0; i < 1000; i++){
        input = [NSString stringWithString:passphrase];
        passphrase = [input SHA256Digest];
    }
    
    return passphrase;
}

- (NSString *)signedPath:(NSString *)path
{
    NSString *signedPath = [path signWithPrivateKey:[self.credentials.privateKey dataUsingEncoding:NSUTF8StringEncoding]
                                         passphrase:[self passphrase]];
    return signedPath;
};


@end