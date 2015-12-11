//
//  ChoiceCircleViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/11.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"


typedef void (^ChoiceCircleBlock) (NSArray * circles);

/**
 *  选择圈子 多选
 */
@interface ChoiceCircleViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>


/**
 *  设置圈子回调
 *
 *  @param block
 */
- (void)setCircleBlock:(ChoiceCircleBlock)block;

@end
