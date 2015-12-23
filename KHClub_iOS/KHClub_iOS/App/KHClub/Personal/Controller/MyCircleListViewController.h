//
//  MyCircleListViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/9.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "RefreshViewController.h"

//我的圈子列表或者其他人的
@interface MyCircleListViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

/**
 *  查询的用户ID
 */
@property (nonatomic, assign) NSInteger userId;

@end
