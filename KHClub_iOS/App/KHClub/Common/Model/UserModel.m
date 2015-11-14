//
//  UserModel.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/12.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel


- (void)setModelWithDic:(NSDictionary *)dic
{
    
    self.uid             = [dic[@"id"] intValue];
    self.head_image      = dic[@"head_image"];
    self.head_sub_image  = dic[@"head_sub_image"];
    self.name            = dic[@"name"];
    self.password        = dic[@"password"];
    self.username        = dic[@"username"];
    self.phone_num       = dic[@"phone_num"];
    self.company_name    = dic[@"company_name"];
    self.e_mail          = dic[@"e_mail"] ;
    self.sex             = [dic[@"sex"] intValue];
    self.kh_id           = dic[@"kh_id"];
    self.birthday        = dic[@"birthday"];
    self.qr_code         = dic[@"qr_code"];
    self.birthday        = dic[@"birthday"];
    self.address         = dic[@"address"];
    self.signature       = dic[@"signature"];
    self.job             = dic[@"job"];
    self.login_token     = dic[@"login_token"];
    self.im_token        = dic[@"im_token"];
    self.iosdevice_token = dic[@"iosdevice_token"];
    self.company_state   = [dic[@"company_state"] intValue];
    self.address_state   = [dic[@"address_state"] intValue];
    self.email_state     = [dic[@"email_state"] intValue];
    self.phone_state     = [dic[@"phone_state"] intValue];
    
}

@end
