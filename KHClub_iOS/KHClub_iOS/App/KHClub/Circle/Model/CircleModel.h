//
//  CircleModel.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/30.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  圈子类型
 */
typedef NS_ENUM(NSInteger, CircleType){
    /**
     *  其他
     */
    CircleOther      = 1000,
    /**
     *  创业投资
     */
    CircleInvestment = 1001,
    /**
     *  商业协会
     */
    CircleBusiness   = 1002,
    /**
     *  茗品沉香
     */
    CircleTea        = 1003,
    /**
     *  名酒雪茄
     */
    CircleCigar      = 1004,
    /**
     *  金融理财
     */
    CircleWealthy    = 1005,
    /**
     *  艺术收藏
     */
    CircleArt        = 1006,
    /**
     *  高端旅游
     */
    CircleTour       = 1007,
    /**
     *  高尔夫
     */
    CircleGolf       = 1008,
    /**
     *  商学院
     */
    CircleCollege    = 1009,
    /**
     *  时尚奢侈品
     */
    CircleFashion    = 1010,
    /**
     *  豪车游艇
     */
    CircleBoat       = 1011
};

/**
 *  圈子详情
 */
@interface CircleModel : NSObject

//ID
@property (nonatomic, assign) NSInteger cid;
//标题
@property (nonatomic, copy  ) NSString  * circle_name;
//描述
@property (nonatomic, copy  ) NSString  * circle_detail;
//图片
@property (nonatomic, copy  ) NSString  * circle_cover_image;
//图片
@property (nonatomic, copy  ) NSString  * circle_cover_sub_image;
//管理员ID
@property (nonatomic, assign) NSInteger managerId;
//管理员姓名
@property (nonatomic, copy  ) NSString  * manager_name;
//联系方式
@property (nonatomic, copy  ) NSString  * phone_num;
//地址
@property (nonatomic, copy  ) NSString  * address;
//微信号
@property (nonatomic, copy  ) NSString  * wx_num;
//微信二维码
@property (nonatomic, copy  ) NSString  * wx_qrcode;
//关注数量
@property (nonatomic, assign) NSInteger follow_quantity;
//是否已经关注
@property (nonatomic, assign) BOOL      isFollow;
//网页
@property (nonatomic, copy  ) NSString  * circle_web;
//未读消息数量
@property (nonatomic, assign) NSInteger unread_count;
//圈子类型
@property (nonatomic, assign) CircleType circleType;

@end