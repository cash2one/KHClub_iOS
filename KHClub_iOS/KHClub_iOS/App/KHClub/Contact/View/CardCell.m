//
//  CardCell.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CardCell.h"

#import "UIImageView+WebCache.h"

@interface CardCell()

//头像
@property (nonatomic, strong) CustomImageView * headImageView;
//姓名
@property (nonatomic, strong) CustomLabel * nameLabel;
//职位
@property (nonatomic, strong) CustomLabel * jobLabel;
//签名
@property (nonatomic, strong) CustomLabel * companyLabel;
//line
@property (nonatomic, strong) UIView * lineView;

@end

@implementation CardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.headImageView = [[CustomImageView alloc] init];
        self.nameLabel     = [[CustomLabel alloc] init];
        self.jobLabel      = [[CustomLabel alloc] init];
        self.companyLabel  = [[CustomLabel alloc] init];
        self.lineView      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.jobLabel];
        [self.contentView addSubview:self.companyLabel];
        [self.contentView addSubview:self.lineView];
        
        [self configUI];
        
    }
    
    return self;
}

- (void)configUI
{
    self.headImageView.frame               = CGRectMake(10, 10, 45, 45);
    self.headImageView.layer.cornerRadius  = 2;
    self.headImageView.layer.masksToBounds = YES;

    self.nameLabel.frame                   = CGRectMake(self.headImageView.right+10, self.headImageView.y+3, 0, 20);
    self.nameLabel.font                    = [UIFont systemFontOfSize:FontListName];
    self.nameLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];

    self.companyLabel.frame                = CGRectMake(self.headImageView.right+10, self.nameLabel.bottom+1, 220, 20);
    self.companyLabel.font                 = [UIFont systemFontOfSize:13];
    self.companyLabel.textColor            = [UIColor colorWithHexString:ColorLightBlack];

    self.jobLabel.frame                    = CGRectMake(self.nameLabel.right+5, self.nameLabel.y, 220, 20);
    self.jobLabel.font                     = [UIFont systemFontOfSize:FontListContent];
    self.jobLabel.textColor                = [UIColor colorWithHexString:ColorDeepGary];

    self.lineView.frame                    = CGRectMake(10, 64, [DeviceManager getDeviceWidth], 1);
    self.lineView.backgroundColor          = [UIColor colorWithHexString:ColorLightGary];
    
}

- (void)setContentWithModel:(CardModel *)model
{
    //头像
    NSURL * imageUrl       = [NSURL URLWithString:[ToolsManager completeUrlStr:model.head_sub_image]];
    [self.headImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    //姓名
    NSString * name        = [ToolsManager emptyReturnNone:model.name];
    CGSize size            = [ToolsManager getSizeWithContent:name andFontSize:15 andFrame:CGRectMake(0, 0, 200, 30)];
    self.nameLabel.text    = name;
    self.nameLabel.width   = size.width;
    //公司
    self.companyLabel.text = [ToolsManager emptyReturnNone:model.company_name];
    //职位
    self.jobLabel.x        = self.nameLabel.right+5;
    self.jobLabel.text     = [ToolsManager emptyReturnNone:model.job];
    
}

@end
