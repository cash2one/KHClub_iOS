//
//  PersonalInfoView.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/3.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

/**
 *  个人信息View
 */
@interface PersonalInfoView : UIView

/**
 *  统一初始化方法
 *
 *  @param frame  frame
 *  @param isSelf 是否是自己
 *
 *  @return UIView
 */
- (instancetype)initWithFrame:(CGRect)frame isSelf:(BOOL)isSelf;

/**
 *  设置个人数据
 */
- (void)setSelfData;

/**
 *  设置别人的数据
 */
- (void)setDataWithModel:(UserModel *)user;

@end
