//
//  CircleNoticeModel.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleNoticeModel.h"

@implementation CircleNoticeModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.comment_arr = [[NSMutableArray alloc] init];
        self.like_arr    = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
