//
//  LikeListCell.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/6/22.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "LikeListCell.h"
#import "UIImageView+WebCache.h"

@interface LikeListCell()

//头像
@property (nonatomic, strong) CustomImageView * headImageView;
//姓名
@property (nonatomic, strong) CustomLabel * nameLabel;
//职位
@property (nonatomic, strong) CustomLabel * jobLabel;
//line
@property (nonatomic, strong) UIView * lineView;

@end

@implementation LikeListCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.headImageView = [[CustomImageView alloc] init];
        self.nameLabel     = [[CustomLabel alloc] init];
        self.jobLabel      = [[CustomLabel alloc] init];
        self.lineView      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.jobLabel];
        [self.contentView addSubview:self.lineView];
        
        [self configUI];
        
    }
    
    return self;
}

- (void)configUI
{
    self.headImageView.frame               = CGRectMake(10, 10, 35, 35);
    self.headImageView.layer.cornerRadius  = 2;
    self.headImageView.layer.masksToBounds = YES;
    
    self.nameLabel.frame                   = CGRectMake(self.headImageView.right+10, self.headImageView.y, 200, 20);
    self.nameLabel.font                    = [UIFont systemFontOfSize:FontListName];
    self.nameLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];
    
    //职位
    self.jobLabel.frame                       = CGRectMake(self.headImageView.right+10, self.nameLabel.bottom, 150, 20);
    self.jobLabel.textColor                   = [UIColor colorWithHexString:ColorLightBlack];
    self.jobLabel.font                        = [UIFont systemFontOfSize:FontComment-2];
    
    self.lineView.frame                    = CGRectMake(0, 59, [DeviceManager getDeviceWidth], 1);
    self.lineView.backgroundColor          = [UIColor colorWithHexString:ColorLightGary];
    
}

- (void)setContentWithModel:(LikeModel *)model
{
    //头像
    NSURL * imageUrl    = [NSURL URLWithString:[ToolsManager completeUrlStr:model.head_sub_image]];
    [self.headImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    //姓名
    self.nameLabel.text = [ToolsManager emptyReturnNone:model.name];
    //职位
    self.jobLabel.text  = model.job;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
