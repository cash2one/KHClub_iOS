//
//  NewsUtils.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/8/19.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "NewsUtils.h"

@implementation NewsUtils

//获取合适的比例
+ (CGRect)getRectWithSize:(CGSize) size
{
    CGFloat width,height;
    if (size.width > size.height) {
        if (size.width > 200) {
            width  = 200;
        }else{
            width  = size.width;
        }

        height = size.height*(width/size.width);
    }else{
        if (size.height > 230) {
            height  = 230;
        }else{
            height  = size.height;
        }
        width = size.width*(height/size.height);
    }
    CGRect rect = CGRectMake(0, 0, width, height);
    
    return rect;
}

@end
