//
//  UserService.m
//  UBaby_iOS
//
//  Created by bhczmacmini on 14-10-27.
//  Copyright (c) 2014年 bhczmacmini. All rights reserved.
//

#import "UserService.h"
#import "DatabaseService.h"
@implementation UserService

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = [[UserModel alloc] init];
    }
    return self;
}

/*! 返回用户服务单例*/
+ (instancetype)sharedService
{

    static UserService * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserService alloc] init];

    });
    
    return instance;
}

- (void)setDeviceToken:(NSString *)deviceToken
{
    //<3ccd76ea 527d5d04 3b743b4c af4e7993 c811c6ca 65b2837b 8e3d47c7 72f9bd6f>
    //token格式处理
    if ([deviceToken hasPrefix:@"<"]) {
        deviceToken = [deviceToken substringFromIndex:1];
    }
    
    if ([deviceToken hasSuffix:@">"]) {
        deviceToken = [deviceToken substringToIndex:deviceToken.length-1];
    }
    
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    _deviceToken = [deviceToken copy];
    
}

- (void)saveDeviceToken
{
    if (self.deviceToken.length > 1) {
        if ([UserService sharedService].user.uid > 0) {
//            NSString * path = kBindDeviceTokenPath;
//            NSDictionary * parameterDic = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.id],
//                                            @"ios_device":self.deviceToken};
//            
//            debugLog(@"%@ %@", path, parameterDic);
//            
//            [NetManager managerPostRequest:path withParameter:parameterDic success:^(NSMutableDictionary *dic) {
//                
//            } failed:^(NSString *err) {
//                debugLog(@"成功失败都无返回值");
//            }];
        }
        
    }
}


//保存数据
- (void)saveAndUpdate
{
    
    //清空
    [self clear];
    NSString * insertSql = [NSString stringWithFormat:@"insert into kh_user (id,username,name,kh_id,sex,phone_num,company_name,address,head_image,head_sub_image,job,birthday,e_mail,signature,qr_code,login_token,im_token,iosdevice_token,company_state,address_state,email_state,phone_state) values ('%ld', '%@', '%@', '%@', '%ld', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%ld', '%ld', '%ld', '%ld')", _user.uid, _user.username, _user.name, _user.kh_id, _user.sex,_user.phone_num, _user.company_name, _user.address ,_user.head_image, _user.head_sub_image, _user.job, _user.birthday, _user.e_mail, _user.signature, _user.qr_code, _user.login_token, _user.im_token, _user.iosdevice_token, _user.company_state, _user.address_state, _user.email_state, _user.phone_state];

    //插入
    [[DatabaseService sharedInstance] executeUpdate:insertSql];

}

//获取缓存数据
- (void)find
{
    //(id,free_count,account,dr_cr,name,sex,passwd,mob_no,mailadd,medical_card,idcard_w,image,role_id,level_id)
    NSString * selectSql = @"select * from kh_user Limit 1";
    FMResultSet * rs = [[DatabaseService sharedInstance] executeQuery:selectSql];
    
    while (rs.next) {
        _user.uid             = [[rs stringForColumn:@"id"] integerValue];
        _user.username        = [rs stringForColumn:@"username"];
        _user.name            = [rs stringForColumn:@"name"];
        _user.kh_id           = [rs stringForColumn:@"kh_id"];
        _user.sex             = [rs intForColumn:@"sex"];
        _user.phone_num       = [rs stringForColumn:@"phone_num"];
        _user.company_name    = [rs stringForColumn:@"company_name"];
        _user.address         = [rs stringForColumn:@"address"];
        _user.head_image      = [rs stringForColumn:@"head_image"];
        _user.head_sub_image  = [rs stringForColumn:@"head_sub_image"];
        _user.job             = [rs stringForColumn:@"job"];
        _user.birthday        = [rs stringForColumn:@"birthday"];
        _user.e_mail          = [rs stringForColumn:@"e_mail"];
        _user.signature       = [rs stringForColumn:@"signature"];
        _user.qr_code         = [rs stringForColumn:@"qr_code"];
        _user.login_token     = [rs stringForColumn:@"login_token"];
        _user.im_token        = [rs stringForColumn:@"im_token"];
        _user.iosdevice_token = [rs stringForColumn:@"iosdevice_token"];
        _user.company_state   = [rs intForColumn:@"company_state"];
        _user.address_state   = [rs intForColumn:@"address_state"];
        _user.email_state     = [rs intForColumn:@"email_state"];
        _user.phone_state     = [rs intForColumn:@"phone_state"];
        
        break;
    }
    
    [rs close];
}

- (void)clear
{
    NSString * deleteSql = @"delete from kh_user";
    //清空
    [[DatabaseService sharedInstance] executeUpdate:deleteSql];
}

@end
