//
//  HttpService.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/9.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "HttpService.h"
#import "HttpCache.h"
@implementation HttpService
{
    AFHTTPRequestOperationManager * _manager;
}

static HttpService * instance;

+ (instancetype)manager {
    
    if (!instance) {
        instance = [[HttpService alloc] init];
    }
    return instance;
}

+ (void)getWithUrlString:(NSString *)urlStr andCompletion:(SuccessBlock)success andFail:(FailBlock)fail
{
    AFHTTPRequestOperationManager * manager = [[HttpService manager] createAFEntity];
    //token传输
    urlStr = [urlStr stringByAppendingFormat:@"&login_token=%@&login_user=%ld", [UserService sharedService].user.login_token, [UserService sharedService].user.uid];
   [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            @try {
                //缓存
                if (operation != nil) {
                    [HttpCache cacheHandleWith:responseObject andUrl:urlStr];
                }
                success(operation, responseObject);
            }
            @catch (NSException *exception) {
                 fail(operation, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail(operation, error);
        }
    }];

}

+ (void)postWithUrlString:(NSString *)urlStr params:(NSDictionary *)params andCompletion:(SuccessBlock)success andFail:(FailBlock)fail
{
    AFHTTPRequestOperationManager * manager = [[HttpService manager] createAFEntity];
    NSMutableDictionary * finalDic          = [NSMutableDictionary dictionaryWithDictionary:params];
    //存在token
    if ([UserService sharedService].user.login_token != nil) {
        [finalDic setObject:[UserService sharedService].user.login_token forKey:@"login_token"];
        [finalDic setObject:[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid] forKey:@"login_user"];
    }
    [manager POST:urlStr parameters:finalDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            @try {
                success(operation, responseObject);
            }
            @catch (NSException *exception) {
                fail(operation, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail(operation, error);
        }
    }];
}

    //files格式 @{FileDataKey:UIImageJPEGRepresentation(image, 0.8),FileNameKey:fileName}
+ (void)postFileWithUrlString:(NSString *)urlStr params:(NSDictionary *)params files:(NSArray *)files andCompletion:(SuccessBlock)success andFail:(FailBlock)fail
{
    AFHTTPRequestOperationManager * manager = [[HttpService manager] createAFEntity];
    NSMutableDictionary * finalDic          = [NSMutableDictionary dictionaryWithDictionary:params];
    //存在token
    if ([UserService sharedService].user.login_token != nil) {
        [finalDic setObject:[UserService sharedService].user.login_token forKey:@"login_token"];
        [finalDic setObject:[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid] forKey:@"login_user"];        
    }
    [manager POST:urlStr parameters:finalDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (files != nil && files.count >0) {
            for (NSDictionary * file in files) {
                [formData appendPartWithFileData:file[FileDataKey] name:file[FileNameKey] fileName:file[FileNameKey] mimeType:@""];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            @try {
                success(operation, responseObject);
            }
            @catch (NSException *exception) {
                fail(operation, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail(operation, error);
        }
    }];

}

//创建AF实体
- (AFHTTPRequestOperationManager *)createAFEntity
{
    if (_manager == nil) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    _manager.requestSerializer                         = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer                        = [AFJSONResponseSerializer serializer];
    _manager.requestSerializer.timeoutInterval         = 30.0f;
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    return _manager;
    
}

@end
