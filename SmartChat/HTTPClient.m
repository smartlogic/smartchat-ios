#import "HTTPClient.h"
#import "Credentials.h"

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
        self.baseURL = [NSURL URLWithString:@"http://roberto.local:9000"];
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
    [self.manager GET:[self.baseURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

@end