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


+ (id)clientWithClient:(HTTPClient *)client credentials:(Credentials *)credentials
{
    return [[HTTPClient alloc] initWithClient:client credentials:credentials];
}

- (id)init
{
    self = [super init];
    if(self){
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:(NSJSONWritingPrettyPrinted)];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager = manager;
    }
    
    return self;
}

- (id)initWithBaseURL:(NSURL *)baseURL credentials:(Credentials *)credentials
{
    self = [self init];
    if(self){
        self.baseURL = baseURL;
        self.credentials = credentials;
    }

    return self;
}

- (id)initWithClient:(HTTPClient *)client credentials:(Credentials *)credentials
{
    return [self initWithBaseURL:client.baseURL credentials:credentials];
}

- (void)getRootResource:(void (^)(YBHALResource *resource))success
                failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure
{
    if(self.credentials && self.credentials.username && self.credentials.password && self.credentials.privateKey){
        NSString *signedPath = [self signedPath:self.baseURL.absoluteString];
        [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.credentials.username password:signedPath];
    }
    
    [self.manager GET:self.baseURL.absoluteString parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  DDLogVerbose(@"getRootResource - responseObject:\n%@", responseObject);
                  success([responseObject HALResourceWithBaseURL:self.baseURL]);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(operation, error);
              }];
}

- (void)authenticate:(YBHALLink *)link
            username:(NSString *)username
            password:(NSString *)password
             success:(void (^)(YBHALResource *, NSString *))success
             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username
                                                                   password:password];
    
    [self.manager POST:[link.URL absoluteString]
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   DDLogVerbose(@"authenticate - responseObject:\n%@", responseObject);
                   YBHALResource *resource = [responseObject HALResourceWithBaseURL:self.baseURL];
                   NSString *privateKey = [resource objectForKeyedSubscript:@"private_key"];
                   success(resource, privateKey);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   failure(operation, error);
               }];
}

- (void)upload:(YBHALLink *)link
    recipients:(NSArray *)recipients
          file:(UIImage *)file
       overlay:(UIImage *)overlay
           ttl:(NSUInteger)ttl
       success:(void (^)(YBHALResource *resource))success
       failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure
{
    NSString *signedPath = [self signedPath:link.URL.absoluteString];
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.credentials.username password:signedPath];
    
    NSDictionary *parameters = @{
                                 @"media": @{
                                         @"friend_ids": recipients,
                                         @"file_name": @"smarch.png",
                                         @"file": [UIImagePNGRepresentation(file) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
                                         }
                                 };
    
    [self.manager POST:link.URL.absoluteString
            parameters:parameters
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   DDLogVerbose(@"upload - responseObject:\n%@", responseObject);
                   success([responseObject HALResourceWithBaseURL:self.baseURL]);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   failure(operation, error);
               }];
}

- (void)registerDevice:(YBHALLink *)link
               success:(void (^)(YBHALResource *resource))success
               failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure
{
    NSString *signedPath = [self signedPath:link.URL.absoluteString];
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.credentials.username password:signedPath];
    
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    NSDictionary *parameters = @{@"device_id": uuid.UUIDString,
                                 @"device_type": @"iOS"};
    
    [self.manager POST:link.URL.absoluteString
            parameters:parameters
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   DDLogVerbose(@"registerDevice - responseObject:\n%@", responseObject);
                   success([responseObject HALResourceWithBaseURL:self.baseURL]);
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


- (BOOL)authenticated
{
    return self.credentials.authenticated;
}

@end