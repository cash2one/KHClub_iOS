//
//  UserModel.h
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/12.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  性别
 */
typedef NS_ENUM(NSInteger, KHSex) {
    /**
     *  男
     */
    SexMale  = 0,
    /**
     *  女
     */
    SexFemale = 1
};

/**
 *  可见状态
 */
typedef NS_ENUM(NSInteger, KHSeeState) {
    /**
     *  所有人可见
     */
    SeeAll  = 0,
    /**
     *  仅好友可见
     */
    SeeOnlyFriends = 1
};

/*! 用户模型*/
@interface UserModel : NSObject

/*! 用户id*/
@property (nonatomic, assign) NSInteger uid;

/*! 用户名*/
@property (nonatomic, copy) NSString * username;

/*! 密码*/
@property (nonatomic, copy) NSString * password;

/*! kh_id*/
@property (nonatomic, copy) NSString * kh_id;

/*! 姓名*/
@property (nonatomic, copy) NSString * name;

/*! 电话号*/
@property (nonatomic, copy) NSString * phone_num;

/*! 姓别 0男 1女 2不知道*/
@property (nonatomic, assign) KHSex sex;

/*! 公司*/
@property (nonatomic, copy) NSString * company_name;

/*! 地址*/
@property (nonatomic, copy) NSString * address;

/*! 头像地址*/
@property (nonatomic, copy) NSString * head_image;

/*! 头像缩略图地址*/
@property (nonatomic, copy) NSString * head_sub_image;

/*! 职位*/
@property (nonatomic, copy) NSString * job;

/*! 生日*/
@property (nonatomic, copy) NSString * birthday;

/*! 签名*/
@property (nonatomic, copy) NSString * signature;

/*! 邮箱*/
@property (nonatomic, copy) NSString * e_mail;

/*! 二维码*/
@property (nonatomic, copy) NSString * qr_code;

/*! 登录token*/
@property (nonatomic, copy) NSString * login_token;

/*! 融云im_token*/
@property (nonatomic, copy) NSString * im_token;

/*! ios设备token*/
@property (nonatomic, copy) NSString * iosdevice_token;

/*! 公司可见状态*/
@property (nonatomic, assign) KHSeeState company_state;
/*! 住址可见状态*/
@property (nonatomic, assign) KHSeeState address_state;
/*! 邮箱可见状态*/
@property (nonatomic, assign) KHSeeState email_state;
/*! 电话可见状态*/
@property (nonatomic, assign) KHSeeState phone_state;


- (void)setModelWithDic:(NSDictionary *)dic;

@end
