//
//  CategoryView.h
//  KHClub_iOS
//
//  Created by 李晓航 on 16/1/5.
//  Copyright © 2016年 JLXC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  圈子类别View
 */
@interface CategoryView : UIButton

/**
 *  初始化入口
 *
 *  @param title 标题
 *  @param tag 类型代码
 *
 *  @return instance
 */
- (instancetype)initWithTitle:(NSString *)title andTag:(NSInteger)tag;

@end
