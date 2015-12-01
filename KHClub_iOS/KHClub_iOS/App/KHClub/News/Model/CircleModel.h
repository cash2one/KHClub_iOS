//
//  CircleModel.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/30.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  圈子详情
 */
@interface CircleModel : NSObject

//ID
@property (nonatomic, assign) NSInteger cid;
//标题
@property (nonatomic, copy  ) NSString  * title;
//描述
@property (nonatomic, copy  ) NSString  * intro;
//图片
@property (nonatomic, copy  ) NSString  * image;
//管理员姓名
@property (nonatomic, copy  ) NSString  * manager_name;
//联系方式
@property (nonatomic, copy  ) NSString  * phone_num;
//地址
@property (nonatomic, copy  ) NSString  * address;
//微信号
@property (nonatomic, copy  ) NSString  * wx_num;
//网页
@property (nonatomic, copy  ) NSString  * web;
//删除标识
@property (nonatomic, assign) NSInteger delete_flag;

@end
