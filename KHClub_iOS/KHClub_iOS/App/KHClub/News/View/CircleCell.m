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
@property (nonatomic, strong) CustomLabel * nameLabel;
//签名
@property (nonatomic, strong) CustomLabel * introLabel;
//line
@property (nonatomic, strong) UIView * lineView;

@end

@implementation CircleCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.headImageView = [[CustomImageView alloc] init];
        self.nameLabel     = [[CustomLabel alloc] init];
        self.introLabel  = [[CustomLabel alloc] init];
        self.lineView      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.introLabel];
        [self.contentView addSubview:self.lineView];
        
        [self configUI];
        
    }
    
    return self;
}

- (void)configUI
{
    self.headImageView.frame               = CGRectMake(10, 10, 45, 45);
    self.headImageView.layer.cornerRadius  = 1;
    self.headImageView.layer.masksToBounds = YES;

    self.nameLabel.frame                   = CGRectMake(self.headImageView.right+5, self.headImageView.y+1, 250, 20);
    self.nameLabel.font                    = [UIFont systemFontOfSize:FontListName];
    self.nameLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];

    self.introLabel.frame                  = CGRectMake(self.headImageView.right+5, self.nameLabel.bottom+3, 250, 20);
    self.introLabel.font                   = [UIFont systemFontOfSize:13];
    self.introLabel.textColor              = [UIColor colorWithHexString:ColorLightBlack];

    self.lineView.frame                    = CGRectMake(10, 64, [DeviceManager getDeviceWidth], 1);
    self.lineView.backgroundColor          = [UIColor colorWithHexString:ColorLightGary];
    
}

- (void)setContentWithModel:(CircleModel *)model
{
    //头像
    NSURL * imageUrl       = nil;
    if (model.image.length > 0) {
        imageUrl = [NSURL URLWithString:[ToolsManager completeUrlStr:[model.image componentsSeparatedByString:@","][0]]];
    }
    [self.headImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"loading_default"]];
    //名字
    self.nameLabel.text  = model.title;
    //公司
    self.introLabel.text = [ToolsManager emptyReturnNone:model.intro];
    
}


@end
