#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@interface BSHttpRequest : NSObject

+ (void)GET:(NSString *)URLString
        parameters:(id)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

+ (void)POST:(NSString *)URLString
        parameters:(id)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError * error))failure;
//归档的工具方法
+ (void)archiverObject:(id)object ByKey:(NSString *)key
              WithPath:(NSString *)path;

+ (id)unarchiverObjectByKey:(NSString *)key
                   WithPath:(NSString *)path;

@end
