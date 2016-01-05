//
//  CircleCategoryViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 16/1/5.
//  Copyright © 2016年 JLXC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^CircleCategoryBlock) (NSInteger typeCode);

/**
 *  选择类别VC
 */
@interface CircleCategoryViewController : BaseViewController

/**
 *  设置完成回调
 *
 *  @param block
 */
- (void)setFinishBlock:(CircleCategoryBlock)block;

/**
 *  提交成功
 */
- (void)postSuccessWithCircleID:(NSInteger)circleID;
/**
 *  提示失败
 */
- (void)showFail;

/**
 *  提示异常
 */

- (void)showException;

@end
