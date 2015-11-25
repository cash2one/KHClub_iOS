//
//  PersonalInfoView.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/3.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "PersonalInfoView.h"
#import "UIImageView+WebCache.h"
#import "HttpService.h"

@interface PersonalInfoView()

//头像
@property (nonatomic, strong) CustomImageView * headImageView;
//二维码
@property (nonatomic, strong) CustomImageView * qrcodeImageView;
//名字 和 工作名
@property (nonatomic, strong) CustomLabel * nameLabel;
//二级名字
@property (nonatomic, strong) CustomLabel * secondNameLabel;
//收藏按钮
@property (nonatomic, strong) CustomButton * collectBtn;
////工作名
//@property (nonatomic, strong) CustomLabel * jobLabel;
//公司名
@property (nonatomic, strong) CustomLabel * companyLabel;
//公司名
@property (nonatomic, strong) CustomLabel * phoneLabel;
//邮箱
@property (nonatomic, strong) CustomLabel * emailLabel;
//住址
@property (nonatomic, strong) CustomLabel * addressLabel;

@property (nonatomic, assign) BOOL isSelf;

@property (nonatomic, assign) BOOL isUpload;

@property (nonatomic, strong) UserModel * user;

@end

@implementation PersonalInfoView
{
    UIRefreshBlock _block;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#define OriginHeight 190

- (instancetype)initWithFrame:(CGRect)frame isSelf:(BOOL)isSelf
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isSelf = isSelf;
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
    self.headImageView   = [[CustomImageView alloc] init];
    self.nameLabel       = [[CustomLabel alloc] init];
    self.secondNameLabel = [[CustomLabel alloc] init];
    self.collectBtn      = [[CustomButton alloc] init];
//    self.jobLabel        = [[CustomLabel alloc] init];
    self.companyLabel    = [[CustomLabel alloc] init];
    self.phoneLabel      = [[CustomLabel alloc] init];
    self.emailLabel      = [[CustomLabel alloc] init];
    self.addressLabel    = [[CustomLabel alloc] init];
    self.qrcodeImageView = [[CustomImageView alloc] init];
    
    [self addSubview:self.headImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.secondNameLabel];
    [self addSubview:self.collectBtn];
//    [self addSubview:self.jobLabel];
    [self addSubview:self.companyLabel];
    [self addSubview:self.phoneLabel];
    [self addSubview:self.emailLabel];
    [self addSubview:self.addressLabel];
    [self addSubview:self.qrcodeImageView];
    
    [self.collectBtn addTarget:self action:@selector(collectClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

/**
 *  布局
 */
- (void)configUI
{
    self.backgroundColor   = [UIColor whiteColor];
    self.collectBtn.frame  = CGRectMake(self.width-30, 8, 22, 22);
    self.collectBtn.hidden = YES;
    [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collect"] forState:UIControlStateNormal];

    //头像
    self.headImageView.frame               = CGRectMake(kCenterOriginX(70)-10, 6, 70, 70);
    self.headImageView.contentMode         = UIViewContentModeScaleAspectFill;
    self.headImageView.layer.cornerRadius  = 35;
    self.headImageView.layer.borderColor   = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    self.headImageView.layer.borderWidth   = 1;
    self.headImageView.layer.masksToBounds = YES;
    //姓名职位
    self.nameLabel.frame         = CGRectMake(0, self.headImageView.bottom+2, [DeviceManager getDeviceWidth]-20, 20);
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
//    self.nameLabel.frame        = CGRectMake(self.headImageView.right+10, self.headImageView.y+2, 200, 20);
//    self.companyLabel.frame     = CGRectMake(self.headImageView.right+10, self.nameLabel.bottom+8, 200, 20);
//    self.jobLabel.frame         = CGRectMake(self.headImageView.right+10, self.companyLabel.bottom+8, 200, 20);
//
    CustomImageView * companyImageView = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"icon_company"]];
    CustomImageView * phoneImageView   = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone"]];
    CustomImageView * emailImageView   = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"icon_email"]];
    CustomImageView * addressImageView = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"icon_address"]];
    companyImageView.frame             = CGRectMake(10, self.nameLabel.bottom, 25, 25);
    phoneImageView.frame               = CGRectMake(10, companyImageView.bottom-5, 25, 25);
    emailImageView.frame               = CGRectMake(10, phoneImageView.bottom-5, 25, 25);
    addressImageView.frame             = CGRectMake(10, emailImageView.bottom-5, 25, 25);
    
    self.companyLabel.frame     = CGRectMake(phoneImageView.right, companyImageView.y+3, self.width-135, 20);
    self.phoneLabel.frame       = CGRectMake(phoneImageView.right, phoneImageView.y+3, self.companyLabel.width, 20);
    self.emailLabel.frame       = CGRectMake(phoneImageView.right, emailImageView.y+3, self.companyLabel.width, 20);
    self.addressLabel.frame     = CGRectMake(phoneImageView.right, addressImageView.y+3, self.companyLabel.width, 20);
    //字体
    self.nameLabel.font         = [UIFont systemFontOfSize:18];
    self.companyLabel.font      = [UIFont systemFontOfSize:13];
//    self.jobLabel.font          = [UIFont systemFontOfSize:16];
    self.phoneLabel.font        = [UIFont systemFontOfSize:13];
    self.emailLabel.font        = [UIFont systemFontOfSize:13];
    self.addressLabel.font      = [UIFont systemFontOfSize:13];

    //颜色
    self.nameLabel.textColor        = [UIColor colorWithHexString:ColorDeepBlack];
    self.companyLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
//    self.jobLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    self.phoneLabel.textColor       = [UIColor colorWithHexString:ColorDeepBlack];
    self.emailLabel.textColor       = [UIColor colorWithHexString:ColorDeepBlack];
    self.addressLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];

    self.addressLabel.numberOfLines = 0;
    
    [self addSubview:phoneImageView];
    [self addSubview:emailImageView];
    [self addSubview:addressImageView];
    [self addSubview:companyImageView];
    
    //二维码位置
    self.qrcodeImageView.frame = CGRectMake(self.width-95, self.height-95, 95, 95);
    
}

- (void)setSelfData
{
    UserModel * user       = [UserService sharedService].user;
    [self setDataWithModel:user];
}

- (void)setDataWithModel:(UserModel *)user
{
    
    self.user = user;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    
    self.nameLabel.text    = [ToolsManager emptyReturnNone:user.name];
    if (user.job.length > 0) {
        self.nameLabel.text    = [NSString stringWithFormat:@"%@ / %@", self.nameLabel.text, user.job];
    }
    self.companyLabel.text = [ToolsManager emptyReturnNone:user.company_name];
//    self.jobLabel.text     = [ToolsManager emptyReturnNone:user.job];
    self.phoneLabel.text   = [ToolsManager emptyReturnNone:user.phone_num];
    self.emailLabel.text   = [ToolsManager emptyReturnNone:user.e_mail];
    //地址长度可变
    self.addressLabel.text = [ToolsManager emptyReturnNone:user.address];
    CGSize addressSize = [ToolsManager getSizeWithContent:user.address andFontSize:13 andFrame:CGRectMake(0, 0, self.width-135, 60)];
    if (addressSize.height > 20) {
        self.addressLabel.height   = addressSize.height;
        self.height                = OriginHeight+addressSize.height-20;
    }else{
        self.addressLabel.height   = 20;
        self.height                = OriginHeight;
    }
    
    //二维码
    [self setQRcode];
    
    //不是自己 不是好友
    if (!self.isSelf && user.uid != [UserService sharedService].user.uid) {
        
        if (!self.isFriend) {
            self.collectBtn.hidden = NO;
            //收藏了
            if (self.isCollect) {
                [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collected"] forState:UIControlStateNormal];
            }else{
                [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collect"] forState:UIControlStateNormal];
            }
            //权限
            if (user.phone_state == SeeOnlyFriends) {
                self.phoneLabel.text = @"********";
            }
            if (user.email_state == SeeOnlyFriends) {
                self.emailLabel.text = @"********";
            }
            if (user.address_state == SeeOnlyFriends) {
                self.addressLabel.text     = @"********";
                //变换
                self.addressLabel.height   = 20;
                self.height                = OriginHeight;
            }
        }else{
            //如果有备注的话
            if (self.remark.length > 0) {
                self.nameLabel.text    = self.remark;
                if (user.job.length > 0) {
                    self.nameLabel.text    = [NSString stringWithFormat:@"%@ / %@", self.remark, user.job];
                }
            }else{
                self.nameLabel.text    = [ToolsManager emptyReturnNone:user.name];
                if (user.job.length > 0) {
                    self.nameLabel.text    = [NSString stringWithFormat:@"%@ / %@", self.nameLabel.text, user.job];
                }
            }
        }
    }
    
    self.qrcodeImageView.frame = CGRectMake(self.width-95, self.height-95, 95, 95);
    
    //外部刷新
    if (_block) {
        _block();
    }
}

/**
 *  设置二维码
 */
- (void)setQRcode
{
    [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:[kRootAddr stringByAppendingString:self.user.qr_code]]];
    NSString * path = [kGetUserQRCodePath stringByAppendingFormat:@"?user_id=%ld", self.user.uid];
    debugLog(@"%@", path);
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        //成功后
        if (status == HttpStatusCodeSuccess) {
            NSString * qrpath = responseData[HttpResult];
            if (qrpath.length > 0) {
                //存在设置
                [self.qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:[kRootAddr stringByAppendingString:qrpath]]];
                [UserService sharedService].user.qr_code = qrpath;
                [[UserService sharedService] saveAndUpdate];
            }
        }

    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

/**
 *  收藏点击
 *
 *  @param sender btn
 */
- (void)collectClick:(id)sender
{
    if (self.isUpload == NO) {
        self.isUpload  = YES;
        
        NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                                  @"target_id":[NSString stringWithFormat:@"%ld", self.user.uid]};
        
        NSString * path = kCollectCardPath;
        [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collected"] forState:UIControlStateNormal];
        if (self.isCollect) {
            path = kDeleteCardPath;
            [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collect"] forState:UIControlStateNormal];
        }
        self.isCollect = !self.isCollect;
        
        debugLog(@"%@ %@", path, params);
        [HttpService postWithUrlString:path params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
            self.isUpload = NO;
            int status = [responseData[HttpStatus] intValue];
            //成功后
            if (status == HttpStatusCodeSuccess) {

                NSString * toast = KHClubString(@"Personal_OtherPersonal_CancelCollectSuccess");
                if (self.isCollect) {
                    toast = KHClubString(@"Personal_OtherPersonal_CollectSuccess");
                }
                [self.parentVC showHint:toast];
                
            }else{
                //失败后
                self.isCollect = !self.isCollect;
                NSString * toast = KHClubString(@"Personal_OtherPersonal_CollectFail");
                if (self.isCollect) {
                    [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collected"] forState:UIControlStateNormal];
                    toast = KHClubString(@"Personal_OtherPersonal_CancelCollectFail");
                }else{
                    [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collect"] forState:UIControlStateNormal];
                }
                [self.parentVC showHint:toast];
            }
            
        } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.isUpload = NO;
            self.isCollect = !self.isCollect;
            NSString * toast = KHClubString(@"Personal_OtherPersonal_CollectFail");
            if (self.isCollect) {
                [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collected"] forState:UIControlStateNormal];
                toast = KHClubString(@"Personal_OtherPersonal_CancelCollectFail");
            }else{
                [self.collectBtn setBackgroundImage:[UIImage imageNamed:@"iconfont_collect"] forState:UIControlStateNormal];
            }
            [self.parentVC showHint:toast];
        }];
    }
}

- (void)setRefreshBlock:(UIRefreshBlock)block
{
    _block = [block copy];
}

@end
