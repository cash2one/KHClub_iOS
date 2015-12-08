//
//  CircleCell.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/30.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleModel.h"

/**
 *  事件代理
 */
@protocol CircleListDelegate <NSObject>

/**
 *  关注按钮点击
 *
 *  @param model 关注模型
 */
- (void)followCirclePress:(CircleModel *)model;

@end

/**
 *  圈子cell
 */
@interface CircleCell : UITableViewCell

@property (nonatomic, assign) id<CircleListDelegate> delegate;

- (void)setContentWithModel:(CircleModel *)model;

@end
