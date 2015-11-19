//
//  OtherPersonalViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/5.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"

/**
 *  其他人的信息详情
 */
@interface OtherPersonalViewController : BaseViewController

/**
 *  用户ID
 */
@property (nonatomic, assign) NSInteger uid;

/**
 *  刚添加完
 */
@property (nonatomic, assign) BOOL newFriend;

@end
