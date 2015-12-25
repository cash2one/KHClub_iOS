//
//  CircleNoticeModel.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  公告模型
 */
@interface CircleNoticeModel : NSObject

//公告id
@property (nonatomic, assign) NSInteger      nid;
/*! 消息体*/
@property (nonatomic, copy  ) NSString       * content_text;
/*! 发布日期*/
@property (nonatomic, copy  ) NSString       * publish_date;
/*! 评论次数*/
@property (nonatomic, assign) NSInteger      comment_quantity;
/*! 点赞次数*/
@property (nonatomic, assign) NSInteger      like_quantity;
/*! 是否点过赞*/
@property (nonatomic, assign) BOOL           is_like;
/*! 评论数组*/
@property (nonatomic, strong) NSMutableArray * comment_arr;

/*! 点赞数组*/
@property (nonatomic, strong) NSMutableArray * like_arr;

@end
