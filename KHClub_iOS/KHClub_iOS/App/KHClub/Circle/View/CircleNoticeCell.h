//
//  CircleNoticeCell.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//


#import "CircleNoticeModel.h"

@protocol CircleNoticeDelegate <NSObject>

@optional
/*! 发送评论*/
- (void)sendCommentClick:(CircleNoticeModel *)notice;
/*! 点赞或者取消赞点击*/
- (void)likeClick:(CircleNoticeModel *)notice likeOrCancel:(BOOL)flag;
/*! 长按内容*/
- (void)longPressContent:(CircleNoticeModel *)notice andGes:(UILongPressGestureRecognizer *)ges;

@end

@interface CircleNoticeCell : UITableViewCell

@property (nonatomic, weak) id<CircleNoticeDelegate> delegate;

/*! 内容填充*/
- (void)setContentWithModel:(CircleNoticeModel *)notice;

@end
