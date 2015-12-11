//
//  QRcodeCardView.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/20.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "QRcodeCardView.h"

@implementation QRcodeCardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame               = CGRectMake(0, 0, [DeviceManager getDeviceWidth], [DeviceManager getDeviceHeight]);
        self.backgroundColor     = [UIColor colorWithWhite:0.5 alpha:0.5];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [self addGestureRecognizer:tap];
        
        UIView * backView        = [[UIView alloc] initWithFrame:CGRectMake(kCenterOriginX(200), kNavBarAndStatusHeight+100, 200, 200)];
        backView.backgroundColor = [UIColor whiteColor];

        self.imageView           = [[CustomImageView alloc] initWithFrame:CGRectMake(25, 25, 150, 150)];
        
        CustomLabel * titleLabel = [[CustomLabel alloc] initWithFontSize:15];
        titleLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
        titleLabel.text          = KHClubString(@"Message_GroupDetail_QRcodeCard");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.frame         = CGRectMake(0, 0, 200, 30);
        
        [self addSubview:backView];
        [backView addSubview:self.imageView];
        [backView addSubview:titleLabel];
    }
    return self;
}

- (void)show
{
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss:(id)sender
{
    [self removeFromSuperview];
}

@end
