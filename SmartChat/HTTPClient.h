#import <Foundation/Foundation.h>

@class Credentials;
@class AFHTTPRequestOperation;
@class YBHALResource;
@class YBHALLink;

@interface HTTPClient : NSObject

- (id)initWithCredentials:(Credentials *)credentials;
- (void)getRootResource:(void (^)(YBHALResource *resource))success
                failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;
- (void)authenticate:(YBHALLink *)link
             success:(void (^)(YBHALResource *))success
             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
- (void)registerDevice:(YBHALLink *)link
               success:(void (^)(YBHALResource *resource))success
               failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

- (NSString *)signedPath:(NSString *)path;
@end
