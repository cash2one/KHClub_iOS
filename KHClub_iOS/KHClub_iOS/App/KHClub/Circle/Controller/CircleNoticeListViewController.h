//
//  CircleNoticeListViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "RefreshViewController.h"

//公告列表
@interface CircleNoticeListViewController : RefreshViewController

//圈子ID
@property (nonatomic, assign) NSInteger circleID;
//是否是管理员
@property (nonatomic, assign) BOOL      isManager;

@end
