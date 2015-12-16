//
//  ShareAlertPopView.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "ShareAlertPopView.h"

@interface ShareAlertPopView()

/**
 *  分享给好友
 */
@property (nonatomic, strong) CustomButton * shareFriendBtn;
/**
 *  分享给微信
 */
@property (nonatomic, strong) CustomButton * shareWechatBtn;
/**
 *  分享给微信朋友圈
 */
@property (nonatomic, strong) CustomButton * shareWechatMomentBtn;
/**
 *  分享给新浪微博
 */
@property (nonatomic, strong) CustomButton * shareSinaBtn;
/**
 *  分享给QQ空间
 */
@property (nonatomic, strong) CustomButton * shareQzoneBtn;
/**
 *  分享给QQ好友
 */
@property (nonatomic, strong) CustomButton * shareQQBtn;
/**
 *  删除好友
 */
@property (nonatomic, strong) CustomButton * deleteBtn;
/**
 *  备注
 */
@property (nonatomic, strong) CustomButton * remarkBtn;
/**
 *  取消按钮
 */
@property (nonatomic, strong) CustomButton * cancelBtn;

@property (nonatomic, strong) UIView * backView;

@end

@implementation ShareAlertPopView
{
    ShareClickBlock _block;
}

- (instancetype)initWithIsFriend:(BOOL)isFriend
{
    self = [self init];
    if (self) {
        
        _isFriend                 = isFriend;
        self.frame                = CGRectMake(0, 0, [DeviceManager getDeviceWidth], [DeviceManager getDeviceHeight]);
        self.backView             = [[UIView alloc] init];

        self.shareFriendBtn       = [[CustomButton alloc] init];
        self.shareWechatBtn       = [[CustomButton alloc] init];
        self.shareWechatMomentBtn = [[CustomButton alloc] init];
        self.shareSinaBtn         = [[CustomButton alloc] init];
        self.shareQQBtn           = [[CustomButton alloc] init];
        self.shareQzoneBtn        = [[CustomButton alloc] init];
        self.deleteBtn            = [[CustomButton alloc] init];
        self.remarkBtn            = [[CustomButton alloc] init];
        self.cancelBtn            = [[CustomButton alloc] init];
        
        [self addSubview:self.backView];
        [self.backView addSubview:self.shareFriendBtn];
        [self.backView addSubview:self.shareWechatBtn];
        [self.backView addSubview:self.shareWechatMomentBtn];
        [self.backView addSubview:self.shareSinaBtn];
        [self.backView addSubview:self.shareQQBtn];
        [self.backView addSubview:self.shareQzoneBtn];
        [self.backView addSubview:self.deleteBtn];
        [self.backView addSubview:self.remarkBtn];
        [self.backView addSubview:self.cancelBtn];
        
        [self configUI];
        
        self.shareFriendBtn.tag       = ShareAlertFriend;
        self.shareWechatBtn.tag       = ShareAlertWechat;
        self.shareWechatMomentBtn.tag = ShareAlertWechatMoment;
        self.shareSinaBtn.tag         = ShareAlertSina;
        self.shareQQBtn.tag           = ShareAlertQQ;
        self.shareQzoneBtn.tag        = ShareAlertQzone;
        self.deleteBtn.tag            = ShareAlertDelete;
        self.remarkBtn.tag            = ShareAlertRemark;

        //新浪微博删除
        self.shareSinaBtn.hidden = YES;
        
        [self.shareFriendBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareWechatBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareWechatMomentBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareSinaBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareQQBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareQzoneBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.remarkBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn addTarget:self action:@selector(functionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelBtn addTarget:self action:@selector(cancelPop) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/**
 *  位置摆放
 */
- (void)configUI
{
    self.backView.frame             = CGRectMake(0, 0, self.width, 0);
    self.backView.backgroundColor   = [UIColor whiteColor];

    CGFloat space                   = ([DeviceManager getDeviceWidth]-180)/4;
    CGFloat width                   = 45;
    self.shareFriendBtn.frame       = CGRectMake(space, 10, width, width);
    self.shareWechatBtn.frame       = CGRectMake(space*2+60, 10, width, width);
    self.shareWechatMomentBtn.frame = CGRectMake(space*3+120, 10, width, width);
//    self.shareSinaBtn.frame         = CGRectMake(space, width+20, width, width);
    self.shareQzoneBtn.frame        = CGRectMake(space, width+20, width, width);
    self.shareQQBtn.frame           = CGRectMake(space*2+60, width+20, width, width);
    
    [self.shareFriendBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_friend"] forState:UIControlStateNormal];
    [self.shareWechatBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_weixin"] forState:UIControlStateNormal];
    [self.shareWechatMomentBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_pengyouquan"] forState:UIControlStateNormal];
    [self.shareSinaBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_weibo"] forState:UIControlStateNormal];
    [self.shareQzoneBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_qqkongjian"] forState:UIControlStateNormal];
    [self.shareQQBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_qq"] forState:UIControlStateNormal];
    
    //下面是 删除 备注 取消
    self.deleteBtn.frame = CGRectMake(kCenterOriginX(240), 0, 240, 28);
    self.remarkBtn.frame = CGRectMake(kCenterOriginX(240), 0, 240, 28);
    self.cancelBtn.frame = CGRectMake(kCenterOriginX(240), 0, 240, 28);
    
    [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.remarkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deleteBtn setTitle:KHClubString(@"Personal_OtherPersonal_DeleteFriend") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:StringCommonCancel forState:UIControlStateNormal];
    [self.remarkBtn setTitle:KHClubString(@"Personal_OtherPersonal_Remark") forState:UIControlStateNormal];
    
    [self.deleteBtn setBackgroundColor:[UIColor colorWithHexString:ColorGold]];
    [self.cancelBtn setBackgroundColor:[UIColor colorWithHexString:ColorGold]];
    [self.remarkBtn setBackgroundColor:[UIColor colorWithHexString:ColorGold]];

    self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.remarkBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
}

- (void)setShareBlock:(ShareClickBlock)block
{
    _block = [block copy];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if (self.isFriend) {
        self.backView.height  = 240;
        self.deleteBtn.y      = 120;
        self.remarkBtn.y      = self.deleteBtn.bottom+9;
        self.cancelBtn.y      = self.remarkBtn.bottom+9;
        self.remarkBtn.hidden = NO;
        self.deleteBtn.hidden = NO;
    }else{
        self.backView.height  = 170;
        self.cancelBtn.y      = 120;
        self.remarkBtn.hidden = YES;
        self.deleteBtn.hidden = YES;
    }
    
    self.backView.y = self.bottom;
    [UIView animateWithDuration:0.3f animations:^{
        self.backView.y = self.height-self.backView.height;
    }];
    
}

- (void)cancelPop
{
    [UIView animateWithDuration:0.3f animations:^{
        self.backView.y = self.bottom;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cancelPop];
}

- (void)functionClick:(CustomButton *)sender
{
    if (_block) {
        _block(sender.tag);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
