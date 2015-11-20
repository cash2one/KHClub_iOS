//
//  QRcodeCardView.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/20.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  定制名片显示
 */
@interface QRcodeCardView : UIView

/**
 *  二维码图片
 */
@property (nonatomic, strong) CustomImageView * imageView;

- (void)show;

@end
