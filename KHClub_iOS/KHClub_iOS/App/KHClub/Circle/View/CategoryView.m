//
//  CategoryView.m
//  KHClub_iOS
//
//  Created by 李晓航 on 16/1/5.
//  Copyright © 2016年 JLXC. All rights reserved.
//

#import "CategoryView.h"

@implementation CategoryView

- (instancetype)initWithTitle:(NSString *)title andTag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 5;
        self.backgroundColor    = [UIColor colorWithHexString:ColorGold];
        self.titleLabel.font    = [UIFont systemFontOfSize:14];
        self.frame              = CGRectMake(0, 0, 77, 30);
        self.tag                = tag;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
