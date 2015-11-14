//
//  PersonalInfoView.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/3.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "PersonalInfoView.h"
#import "UIImageView+WebCache.h"

@interface PersonalInfoView()

//背景滚动视图
@property (nonatomic, strong) UIScrollView * backScrollView;
//头像
@property (nonatomic, strong) CustomImageView * headImageView;
//名字
@property (nonatomic, strong) CustomLabel * nameLabel;
//二级名字
@property (nonatomic, strong) CustomLabel * secondNameLabel;
//收藏按钮
@property (nonatomic, strong) CustomButton * collectBtn;
//工作名
@property (nonatomic, strong) CustomLabel * jobLabel;
//公司名
@property (nonatomic, strong) CustomLabel * companyLabel;
//公司名
@property (nonatomic, strong) CustomLabel * phoneLabel;
//邮箱
@property (nonatomic, strong) CustomLabel * emailLabel;
//住址
@property (nonatomic, strong) CustomLabel * addressLabel;




@end

@implementation PersonalInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame isSelf:(BOOL)isSelf
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWidget];
        [self configUI];
        
        if (isSelf) {
            [self setSelfData];
        }
    }
    return self;
}


/**
 *  初始化
 */
- (void)initWidget
{
    self.backScrollView  = [[UIScrollView alloc] init];
    self.headImageView   = [[CustomImageView alloc] init];
    self.nameLabel       = [[CustomLabel alloc] init];
    self.secondNameLabel = [[CustomLabel alloc] init];
    self.collectBtn      = [[CustomButton alloc] init];
    self.jobLabel        = [[CustomLabel alloc] init];
    self.companyLabel    = [[CustomLabel alloc] init];
    self.phoneLabel      = [[CustomLabel alloc] init];
    self.emailLabel      = [[CustomLabel alloc] init];
    self.addressLabel    = [[CustomLabel alloc] init];
    
    [self addSubview:self.backScrollView];
    [self.backScrollView addSubview:self.headImageView];
    [self.backScrollView addSubview:self.nameLabel];
    [self.backScrollView addSubview:self.secondNameLabel];
    [self.backScrollView addSubview:self.collectBtn];
    [self.backScrollView addSubview:self.jobLabel];
    [self.backScrollView addSubview:self.companyLabel];
    [self.backScrollView addSubview:self.phoneLabel];
    [self.backScrollView addSubview:self.emailLabel];
    [self.backScrollView addSubview:self.addressLabel];
}

/**
 *  布局
 */
- (void)configUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.backScrollView.frame                          = CGRectMake(0, 0, self.width, self.height);
    self.backScrollView.contentSize                    = CGSizeMake(self.width*2, 0);
    self.backScrollView.showsHorizontalScrollIndicator = NO;
    self.backScrollView.pagingEnabled                  = YES;
    self.backScrollView.bounces = NO;

    //位置
    self.headImageView.frame    = CGRectMake(10, 10, 80, 80);
    self.nameLabel.frame        = CGRectMake(self.headImageView.right+10, self.headImageView.y+2, 200, 20);
    self.companyLabel.frame     = CGRectMake(self.headImageView.right+10, self.nameLabel.bottom+8, 200, 20);
    self.jobLabel.frame         = CGRectMake(self.headImageView.right+10, self.companyLabel.bottom+8, 200, 20);
    
    CustomImageView * phoneImageView   = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"card_phone"]];
    CustomImageView * emailImageView   = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"card_email"]];
    CustomImageView * addressImageView = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"card_location"]];
    phoneImageView.frame               = CGRectMake(self.headImageView.x, self.headImageView.bottom+10, 20, 20);
    emailImageView.frame               = CGRectMake(self.headImageView.x, phoneImageView.bottom+10, 20, 20);
    addressImageView.frame             = CGRectMake(self.headImageView.x, emailImageView.bottom+10, 20, 20);
    
    self.phoneLabel.frame       = CGRectMake(phoneImageView.right+5, self.headImageView.bottom+10, 260, 20);
    self.emailLabel.frame       = CGRectMake(phoneImageView.right+5, self.phoneLabel.bottom+10, 260, 20);
    self.addressLabel.frame     = CGRectMake(phoneImageView.right+5, self.emailLabel.bottom+10, 260, 20);

    //字体
    self.nameLabel.font         = [UIFont systemFontOfSize:18];
    self.companyLabel.font      = [UIFont systemFontOfSize:16];
    self.jobLabel.font          = [UIFont systemFontOfSize:16];
    self.phoneLabel.font        = [UIFont systemFontOfSize:16];
    self.emailLabel.font        = [UIFont systemFontOfSize:16];
    self.addressLabel.font      = [UIFont systemFontOfSize:16];

    //颜色
    self.nameLabel.textColor    = [UIColor colorWithHexString:ColorDeepBlack];
    self.companyLabel.textColor = [UIColor colorWithHexString:ColorDeepBlack];
    self.jobLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    self.phoneLabel.textColor   = [UIColor colorWithHexString:ColorLightBlack];
    self.emailLabel.textColor   = [UIColor colorWithHexString:ColorLightBlack];
    self.addressLabel.textColor = [UIColor colorWithHexString:ColorLightBlack];
    
    [self.backScrollView addSubview:phoneImageView];
    [self.backScrollView addSubview:emailImageView];
    [self.backScrollView addSubview:addressImageView];
    
}

- (void)setSelfData
{
    UserModel * user       = [UserService sharedService].user;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    self.nameLabel.text    = [ToolsManager emptyReturnNone:user.name];
    self.companyLabel.text = [ToolsManager emptyReturnNone:user.company_name];
    self.jobLabel.text     = [ToolsManager emptyReturnNone:user.job];
    self.phoneLabel.text   = [ToolsManager emptyReturnNone:user.phone_num];
    self.emailLabel.text   = [ToolsManager emptyReturnNone:user.e_mail];
    self.addressLabel.text = [ToolsManager emptyReturnNone:user.address];
}

- (void)setDataWithModel:(UserModel *)user
{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    self.nameLabel.text    = [ToolsManager emptyReturnNone:user.name];
    self.companyLabel.text = [ToolsManager emptyReturnNone:user.company_name];
    self.jobLabel.text     = [ToolsManager emptyReturnNone:user.job];
    self.phoneLabel.text   = [ToolsManager emptyReturnNone:user.phone_num];
    self.emailLabel.text   = [ToolsManager emptyReturnNone:user.e_mail];
    self.addressLabel.text = [ToolsManager emptyReturnNone:user.address];
}


@end
