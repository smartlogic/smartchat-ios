#import <Foundation/Foundation.h>

@class Credentials;
@class AFHTTPRequestOperation;
@class YBHALResource;
@class YBHALLink;

@interface HTTPClient : NSObject

+ (id)clientWithClient:(HTTPClient *)client credentials:(Credentials *)credentials;
- (id)initWithBaseURL:(NSURL *)baseURL credentials:(Credentials *)credentials;
- (id)initWithClient:(HTTPClient *)client credentials:(Credentials *)credentials;
- (void)getRootResource:(void (^)(YBHALResource *resource))success
                failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;
- (void)authenticate:(YBHALLink *)link
            username:(NSString *)username
            password:(NSString *)password
             success:(void (^)(YBHALResource *, NSString *privateKey))success
             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)registerDevice:(YBHALLink *)link
               success:(void (^)(YBHALResource *resource))success
               failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;
- (void)upload:(YBHALLink *)link
       recipients:(NSArray *)recipients
             file:(UIImage *)file
          overlay:(UIImage *)overlay
              ttl:(NSUInteger)ttl
          success:(void (^)(YBHALResource *resource))success
          failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

- (NSString *)signedPath:(NSString *)path;
@end
