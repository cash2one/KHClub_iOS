//
//  CircleNewsListCell.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "NewsListCell.h"

/*! 新闻表格cell*/
@interface CircleNewsListCell : UITableViewCell<UIActionSheetDelegate>


@property (nonatomic, weak) id<NewsListDelegate> delegate;

/*! 内容填充*/
- (void)setContentWithModel:(NewsModel *)news withIsManager:(BOOL)isManager;


@end
