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

- (void)setCardBlock:(SelecCardBlock)block;

@end
