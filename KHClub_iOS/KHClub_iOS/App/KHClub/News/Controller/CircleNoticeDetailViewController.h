//
//  CircleNoticeDetailViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"

//公告详情
@interface CircleNoticeDetailViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

//公告ID
@property (nonatomic, assign) NSInteger noticeID;

@end
