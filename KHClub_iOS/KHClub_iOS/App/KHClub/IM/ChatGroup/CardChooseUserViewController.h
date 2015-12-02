//
//  CardChooseUserViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/1.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^SelecCardBlock) (NSString * cardStr);

/**
 *  发送名片的时候 用的选择列表
 */
@interface CardChooseUserViewController : BaseViewController

//当名片消息存在的时候 视为分享到某一个选择的目标
@property (nonatomic, copy) NSString * cardMessage;

- (void)setCardBlock:(SelecCardBlock)block;

@end
