//
//  ShareAlertPopView.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  点击事件枚举
 */
typedef NS_ENUM(NSInteger, ShareAlertType) {
    /**
     *  备注
     */
    ShareAlertRemark       = 1,
    /**
     *  删除好友
     */
    ShareAlertDelete       = 2,
    /**
     *  转发给好友
     */
    ShareAlertFriend       = 3,
    /**
     *  转发到微信
     */
    ShareAlertWechat       = 4,
    /**
     *  转发到朋友圈
     */
    ShareAlertWechatMoment = 5,
    /**
     *  转发到新浪微博
     */
    ShareAlertSina         = 6,
    /**
     *  转发到QQ空间
     */
    ShareAlertQzone        = 7,
    /**
     *  转发到QQ
     */
    ShareAlertQQ           = 8
};

typedef void (^ShareClickBlock) (ShareAlertType type);

/**
 *  右上角点击 分享提示窗
 */
@interface ShareAlertPopView : UIView

/**
 *  初始化方法
 *
 *  @param isFriend 是否是好友
 *
 *  @return View对象
 */
- (instancetype)initWithIsFriend:(BOOL)isFriend;

/**
 *  显示
 *
 *  @param view 目标view
 */
- (void)show;

@property (nonatomic, assign) BOOL isFriend;

/**
 *  设置call back
 *
 *  @param block block
 */
- (void)setShareBlock:(ShareClickBlock)block;

@end
