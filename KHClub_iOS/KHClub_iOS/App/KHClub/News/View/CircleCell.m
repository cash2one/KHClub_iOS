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
//未读数量标签
@property (nonatomic, strong) CustomLabel     * unreadLabel;
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
        self.unreadLabel   = [[CustomLabel alloc] init];
        self.lineView      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.likeLabel];
        [self.contentView addSubview:self.followBtn];
        [self.contentView addSubview:self.unreadLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.followBtn addTarget:self action:@selector(followPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [self configUI];
        
    }
    
    return self;
}

- (void)configUI
{
    //头像
    self.headImageView.frame               = CGRectMake(10, 6, 57, 57);
    self.headImageView.layer.cornerRadius  = 1;
    self.headImageView.contentMode         = UIViewContentModeScaleAspectFill;
    self.headImageView.layer.cornerRadius  = 5;
    self.headImageView.layer.masksToBounds = YES;
    //名字
    self.nameLabel.frame                   = CGRectMake(self.headImageView.right+10, self.headImageView.y+5, 250, 14);
    self.nameLabel.font                    = [UIFont systemFontOfSize:14];
    self.nameLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];
    //关注人数图片
    CustomImageView * likeImageView        = [[CustomImageView alloc] initWithFrame:CGRectMake(self.headImageView.right+10, self.nameLabel.bottom+12, 20, 18)];
    likeImageView.contentMode              = UIViewContentModeScaleAspectFit;
    likeImageView.image                    = [UIImage imageNamed:@"member"];
    [self.contentView addSubview:likeImageView];
    //关注人数
    self.likeLabel.frame                   = CGRectMake(likeImageView.right+7, self.nameLabel.bottom+12, 200, 18);
    self.likeLabel.font                    = [UIFont systemFontOfSize:12];
    self.likeLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];
    //未读数量
    self.unreadLabel.frame                 = CGRectMake([DeviceManager getDeviceWidth]-70, 31, 55, 12);
    self.unreadLabel.font                  = [UIFont systemFontOfSize:12];
    self.unreadLabel.textColor             = [UIColor colorWithHexString:ColorGold];
    self.unreadLabel.textAlignment         = NSTextAlignmentRight;
    self.unreadLabel.hidden                = YES;
    //关注按钮
    self.followBtn.frame                   = CGRectMake([DeviceManager getDeviceWidth]-65, 23, 49, 22);
    [self.followBtn setTitle:KHClubString(@"News_CircleList_Follow") forState:UIControlStateNormal];
    [self.followBtn setTitleColor:[UIColor colorWithHexString:ColorGold] forState:UIControlStateNormal];
    self.followBtn.layer.cornerRadius      = 3;
    self.followBtn.layer.borderColor       = [UIColor colorWithHexString:ColorGold].CGColor;
    self.followBtn.titleLabel.font         = [UIFont systemFontOfSize:13];
    self.followBtn.layer.borderWidth       = 1;
    self.lineView.frame                    = CGRectMake(self.headImageView.right+10, 68, [DeviceManager getDeviceWidth], 1);
    self.lineView.backgroundColor          = [UIColor colorWithHexString:ColorLightGary];
    
}

- (void)setContentWithModel:(CircleModel *)model
{
    self.circleModel = model;

    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:model.circle_cover_sub_image]] placeholderImage:[UIImage imageNamed:@"loading_default"]];
    //名字
    self.nameLabel.text = model.circle_name;
    //公司
    self.likeLabel.text = [NSString stringWithFormat:@"%ld", model.follow_quantity];
    
    if (model.isFollow) {
        self.followBtn.hidden = YES;
    }else{
        self.followBtn.hidden = NO;
    }
    
    //存在则显示
    if (model.unread_count > 0) {
        self.unreadLabel.text   = [@"+ " stringByAppendingFormat:@"%ld", model.unread_count];
        self.unreadLabel.hidden = NO;
    }else{
        self.unreadLabel.hidden = YES;
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
