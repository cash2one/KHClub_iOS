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


//已选的圈子ID
@property (nonatomic, assign) NSInteger circleID;

/**
 *  设置圈子回调
 *
 *  @param block
 */
- (void)setCircleBlock:(ChoiceCircleBlock)block;

/**
 *  提交成功退出
 */
- (void)popToTab;
/**
 *  退出到某一个vc
 */
- (void)popTo:(UIViewController *)vc;
/**
 *  提示失败
 */
- (void)showFail;

/**
 *  提示异常
 */

- (void)showException;

@end
