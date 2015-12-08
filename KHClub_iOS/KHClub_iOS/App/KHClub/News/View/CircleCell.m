//
//  CircleCell.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/30.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleCell.h"
#import "UIImageView+WebCache.h"

@interface CircleCell()

//头像
@property (nonatomic, strong) CustomImageView * headImageView;
//姓名
@property (nonatomic, strong) CustomLabel     * nameLabel;
//关注数量
@property (nonatomic, strong) CustomLabel     * likeLabel;
//关注按钮
@property (nonatomic, strong) CustomButton    * followBtn;
//line
@property (nonatomic, strong) UIView          * lineView;
//持有模型
@property (nonatomic, strong) CircleModel     * circleModel;

@end

@implementation CircleCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.headImageView = [[CustomImageView alloc] init];
        self.nameLabel     = [[CustomLabel alloc] init];
        self.likeLabel     = [[CustomLabel alloc] init];
        self.followBtn     = [[CustomButton alloc] init];
        self.lineView      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.likeLabel];
        [self.contentView addSubview:self.followBtn];
        [self.contentView addSubview:self.lineView];
        
        [self.followBtn addTarget:self action:@selector(followPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [self configUI];
        
    }
    
    return self;
}

- (void)configUI
{
    //头像
    self.headImageView.frame               = CGRectMake(10, 10, 45, 45);
    self.headImageView.layer.cornerRadius  = 1;
    self.headImageView.contentMode         = UIViewContentModeScaleAspectFill;
    self.headImageView.layer.masksToBounds = YES;
    //名字
    self.nameLabel.frame                   = CGRectMake(self.headImageView.right+5, self.headImageView.y+1, 250, 20);
    self.nameLabel.font                    = [UIFont systemFontOfSize:FontListName];
    self.nameLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];
    //关注人数图片
    CustomImageView * likeImageView        = [[CustomImageView alloc] initWithFrame:CGRectMake(self.headImageView.right+5, self.nameLabel.bottom+3, 20, 18)];
    likeImageView.contentMode              = UIViewContentModeScaleAspectFit;
    likeImageView.image                    = [UIImage imageNamed:@"iconfont_friend"];
    [self.contentView addSubview:likeImageView];
    //关注人数
    self.likeLabel.frame                   = CGRectMake(likeImageView.right+5, self.nameLabel.bottom+3, 200, 20);
    self.likeLabel.font                    = [UIFont systemFontOfSize:13];
    self.likeLabel.textColor               = [UIColor colorWithHexString:ColorLightBlack];
    //关注按钮
    self.followBtn.frame                   = CGRectMake([DeviceManager getDeviceWidth]-80, 17, 60, 30);
    self.followBtn.backgroundColor         = [UIColor colorWithHexString:ColorGold];
    [self.followBtn setTitle:KHClubString(@"News_CircleList_Follow") forState:UIControlStateNormal];
    [self.followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.lineView.frame                    = CGRectMake(10, 64, [DeviceManager getDeviceWidth], 1);
    self.lineView.backgroundColor          = [UIColor colorWithHexString:ColorLightGary];
    
}

- (void)setContentWithModel:(CircleModel *)model
{
    self.circleModel = model;
    //头像
    NSURL * imageUrl = nil;
    if (model.image.length > 0) {
        imageUrl = [NSURL URLWithString:[ToolsManager completeUrlStr:[model.image componentsSeparatedByString:@","][0]]];
    }
    [self.headImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"loading_default"]];
    //名字
    self.nameLabel.text = model.title;
    //公司
    self.likeLabel.text = @"11000";
    
    if (model.isFollow) {
        self.followBtn.hidden = YES;
    }else{
        self.followBtn.hidden = NO;
    }
    
}


//点击关注
- (void)followPress:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(followCirclePress:)]) {
        [self.delegate followCirclePress:self.circleModel];
    }
    
}

@end
