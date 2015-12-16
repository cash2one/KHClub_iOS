//
//  PersonalViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/20.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "PersonalViewController.h"
#import "MyNewsListViewController.h"
#import "ImageModel.h"
#import "IMUtils.h"
#import "PersonalInfoView.h"
#import "UIImageView+WebCache.h"
#import "PersonalSettingViewController.h"
#import "ChatViewController.h"
#import "ShareAlertPopView.h"
#import "ShareUtils.h"
#import "CardChooseUserViewController.h"
#import "MyCircleListViewController.h"

@interface PersonalViewController ()

//背景滚动视图
@property (nonatomic, strong) UIScrollView      * backScrollView;
//横版滚动视图
@property (nonatomic, strong) PersonalInfoView  * infoView;
//图片1
@property (nonatomic, strong) CustomImageView   * imageView1;
//图片2
@property (nonatomic, strong) CustomImageView   * imageView2;
//图片3
@property (nonatomic, strong) CustomImageView   * imageView3;
//圈子图片1
@property (nonatomic, strong) CustomImageView   * circleImageView1;
//圈子图片2
@property (nonatomic, strong) CustomImageView   * circleImageView2;
//圈子图片3
@property (nonatomic, strong) CustomImageView   * circleImageView3;
//签名背景
@property (nonatomic, strong) UIView            * signBackView;
//签名
@property (nonatomic, strong) CustomLabel       * signLabel;
//图像背景
@property (nonatomic, strong) CustomButton      * imageBackView;
//图像背景
@property (nonatomic, strong) CustomButton      * myCircleBackView;
//小助手
@property (nonatomic, strong) CustomButton      * robotBackView;
//右上角点击分享按钮
@property (nonatomic, strong) ShareAlertPopView * shareAlertPopView;

@end

@implementation PersonalViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化
    [self initWidget];
    //编辑UI
    [self configUI];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshUI];
}

#pragma mark- layout

- (void)initWidget
{
    //背景滚动视图
    self.backScrollView    = [[UIScrollView alloc] init];
    self.infoView          = [[PersonalInfoView alloc] initWithFrame:CGRectMake(10, 10, self.viewWidth-20, 190) isSelf:YES];
    self.imageView1        = [[CustomImageView alloc] init];
    self.imageView2        = [[CustomImageView alloc] init];
    self.imageView3        = [[CustomImageView alloc] init];
    self.circleImageView1  = [[CustomImageView alloc] init];
    self.circleImageView2  = [[CustomImageView alloc] init];
    self.circleImageView3  = [[CustomImageView alloc] init];
    //状态背景
    self.imageBackView     = [[CustomButton alloc] init];
    //圈子背景
    self.myCircleBackView  = [[CustomButton alloc] init];
    //签名部分
    self.signBackView      = [[UIView alloc] init];
    self.signLabel         = [[CustomLabel alloc] init];
    //客服
    self.robotBackView     = [[CustomButton alloc] init];
    
    [self.view addSubview:self.backScrollView];
    [self.backScrollView addSubview:self.infoView];
    [self.backScrollView addSubview:self.imageBackView];
    [self.backScrollView addSubview:self.myCircleBackView];
    [self.backScrollView addSubview:self.signBackView];
    [self.backScrollView addSubview:self.robotBackView];
    [self.signBackView addSubview:self.signLabel];
    
    [self.imageBackView addSubview:self.imageView1];
    [self.imageBackView addSubview:self.imageView2];
    [self.imageBackView addSubview:self.imageView3];
    
    [self.myCircleBackView addSubview:self.circleImageView1];
    [self.myCircleBackView addSubview:self.circleImageView2];
    [self.myCircleBackView addSubview:self.circleImageView3];
 
    __weak typeof(self) sself = self;
    //左上角设置
    [self.navBar setLeftBtnWithContent:@"" andBlock:^{
        PersonalSettingViewController * psVC= [[PersonalSettingViewController alloc] init];
        [sself pushVC:psVC];
    }];
    [self.navBar setRightBtnWithContent:@"" andBlock:^{
        [sself.shareAlertPopView show];
    }];
    
    self.shareAlertPopView = [[ShareAlertPopView alloc] initWithIsFriend:NO];
    [self.shareAlertPopView setShareBlock:^(ShareAlertType type) {
        switch (type) {
            case ShareAlertFriend:
            {
                [sself sendToFriend];
            }
                break;
            case ShareAlertWechat:
            {
                [ShareUtils shareWechatWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertWechatMoment:
            {
                [ShareUtils shareWechatMomentsWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertSina:
            {
                [ShareUtils shareSinaWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertQQ:
            {
                [ShareUtils shareQQWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertQzone:
            {
                [ShareUtils shareQzoneWithUser:[UserService sharedService].user];
            }
                break;
                
            default:
                break;
        }
        
        [sself.shareAlertPopView cancelPop];
    }];

    
    //设置页面UI刷新
    [self.infoView setRefreshBlock:^{
        sself.imageBackView.y    = self.infoView.bottom+10;
        sself.myCircleBackView.y = self.imageBackView.bottom+1;
        sself.signBackView.y     = self.myCircleBackView.bottom+1;
        sself.robotBackView.y    = self.signBackView.bottom+10;
    }];
    
    [self.imageBackView addTarget:self action:@selector(myImageClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.myCircleBackView addTarget:self action:@selector(myCircleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.robotBackView addTarget:self action:@selector(robotClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configUI
{
 
    [self setNavBarTitle:KHClubString(@"Personal_Personal_Title")];
    
    //背景滚动视图
    self.backScrollView.frame                        = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kTabBarHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;

    //顶部栏设置部分
    self.navBar.leftBtn.hidden                       = NO;
    self.navBar.leftBtn.imageEdgeInsets              = UIEdgeInsetsMake(4, 3, 0, 10);
    self.navBar.leftBtn.imageView.contentMode        = UIViewContentModeScaleAspectFit;
    self.navBar.rightBtn.imageEdgeInsets             = UIEdgeInsetsMake(0, 15, 0, 0);
    self.navBar.rightBtn.imageView.contentMode       = UIViewContentModeScaleAspectFit;
    //名片和设置
    [self.navBar.leftBtn setImage:[UIImage imageNamed:@"personal_info_edit"] forState:UIControlStateNormal];
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"personal_more"] forState:UIControlStateNormal];
    
    //状态背景
    self.imageBackView.frame            = CGRectMake(0, self.infoView.bottom+10, self.viewWidth, 60);
    self.imageBackView.backgroundColor  = [UIColor whiteColor];

    CustomLabel * imageLabel            = [[CustomLabel alloc] initWithFontSize:17];
    imageLabel.textColor                = [UIColor colorWithHexString:ColorDeepBlack];
    imageLabel.frame                    = CGRectMake(15, 0, 80, 60);
    imageLabel.text                     = KHClubString(@"Personal_Personal_Moments");
    [self.imageBackView addSubview:imageLabel];

    self.imageView1.frame               = CGRectMake(imageLabel.right+5, 5, 50, 50);
    self.imageView2.frame               = CGRectMake(self.imageView1.right+5, 5, 50, 50);
    self.imageView3.frame               = CGRectMake(self.imageView2.right+5, 5, 50, 50);
    self.imageView1.contentMode         = UIViewContentModeScaleAspectFill;
    self.imageView2.contentMode         = UIViewContentModeScaleAspectFill;
    self.imageView3.contentMode         = UIViewContentModeScaleAspectFill;
    self.imageView1.layer.masksToBounds = YES;
    self.imageView2.layer.masksToBounds = YES;
    self.imageView3.layer.masksToBounds = YES;
    
    //我的圈子
    self.myCircleBackView.frame               = CGRectMake(0, self.imageBackView.bottom+10, self.viewWidth, 60);
    self.myCircleBackView.backgroundColor     = [UIColor whiteColor];
    CustomLabel * circleLabel                 = [[CustomLabel alloc] initWithFontSize:17];
    circleLabel.textColor                     = [UIColor colorWithHexString:ColorDeepBlack];
    circleLabel.frame                         = CGRectMake(15, 0, 80, 60);
    circleLabel.text                          = KHClubString(@"News_CircleList_MyCircle");
    [self.myCircleBackView addSubview:circleLabel];
    
    self.circleImageView1.frame               = CGRectMake(circleLabel.right+5, 5, 50, 50);
    self.circleImageView2.frame               = CGRectMake(self.circleImageView1.right+5, 5, 50, 50);
    self.circleImageView3.frame               = CGRectMake(self.circleImageView2.right+5, 5, 50, 50);
    self.circleImageView1.contentMode         = UIViewContentModeScaleAspectFill;
    self.circleImageView2.contentMode         = UIViewContentModeScaleAspectFill;
    self.circleImageView3.contentMode         = UIViewContentModeScaleAspectFill;
    self.circleImageView1.layer.masksToBounds = YES;
    self.circleImageView2.layer.masksToBounds = YES;
    self.circleImageView3.layer.masksToBounds = YES;
    
    //签名
    self.signBackView.frame            = CGRectMake(0, self.imageBackView.bottom+1, self.viewWidth, 60);
    self.signBackView.backgroundColor  = [UIColor colorWithHexString:ColorWhite];

    CustomLabel * signTitleLabel       = [[CustomLabel alloc] initWithFontSize:17];
    signTitleLabel.textColor           = [UIColor colorWithHexString:ColorDeepBlack];
    signTitleLabel.frame               = CGRectMake(15, 0, 100, 40);
    signTitleLabel.text                = KHClubString(@"Personal_Personal_Sign");

    self.signLabel.frame               = CGRectMake(15, signTitleLabel.bottom, self.viewWidth-30, 0);
    self.signLabel.textColor           = [UIColor colorWithHexString:ColorDeepBlack];
    self.signLabel.font                = [UIFont systemFontOfSize:15];
    self.signLabel.numberOfLines       = 0;
    self.signLabel.lineBreakMode       = NSLineBreakByCharWrapping;

    self.robotBackView.frame           = CGRectMake(0, self.signBackView.bottom+10, self.viewWidth, 60);
    self.robotBackView.backgroundColor = [UIColor colorWithHexString:ColorWhite];
    CustomLabel * robotTitleLabel      = [[CustomLabel alloc] initWithFontSize:16];
    robotTitleLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    robotTitleLabel.frame              = CGRectMake(65, 10, 200, 40);
    robotTitleLabel.text               = KHClubString(@"Personal_Personal_RobotTitle");

    CustomImageView * robotImageView   = [[CustomImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
    robotImageView.image               = [UIImage imageNamed:@"Icon"];
    
    [self.signBackView addSubview:signTitleLabel];
    [self.robotBackView addSubview:robotImageView];
    [self.robotBackView addSubview:robotTitleLabel];
    
}

- (void)refreshUI
{
    [self.infoView setSelfData];
    //状态更新
    [self getNewsImages];
    [self getCircles];
    //签名
    NSString * signStr       = [ToolsManager emptyReturnNone:[UserService sharedService].user.signature];
    CGSize size              = [ToolsManager getSizeWithContent:signStr andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
    self.signLabel.text      = signStr;
    self.signBackView.height = size.height+50;
    self.signLabel.height    = size.height;

    self.robotBackView.y     = self.signBackView.bottom+10;
    
    if (self.robotBackView.bottom < self.backScrollView.height) {
        self.backScrollView.contentSize = CGSizeMake(0, self.backScrollView.height+1);
    }else{
        self.backScrollView.contentSize = CGSizeMake(0, self.robotBackView.height+10);
    }
    
}

#pragma mark- method response
- (void)myImageClick:(id)sender
{
    MyNewsListViewController * mnlvc = [[MyNewsListViewController alloc] init];
    [self pushVC:mnlvc];
}

/**
 *  客服
 *
 *  @param sender
 */
- (void)robotClick:(id)sender
{
    ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:KH_ROBOT isGroup:NO];
    [self pushVC:chatVC];
}

- (void)sendToFriend
{
    CardChooseUserViewController * ccuvc = [[CardChooseUserViewController alloc] init];
    ccuvc.cardMessage = [[IMUtils shareInstance] generateCardMesssageWithUserModel:[UserService sharedService].user];
    [self presentViewController:ccuvc animated:YES completion:nil];
}

- (void)myCircleClick:(id)sender
{
    MyCircleListViewController * mclvc = [[MyCircleListViewController alloc] init];
    [self pushVC:mclvc];
}

#pragma mark- private method
//获取十张最新状态的图片
- (void)getNewsImages
{
    //kGetNewsImagesPath
    NSString * path = [kGetNewsCoverListPath stringByAppendingFormat:@"?uid=%ld", [UserService sharedService].user.uid];
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            NSArray * imageList = responseData[HttpResult][HttpList];
            
            NSMutableArray * imageModelList = [[NSMutableArray alloc] init];
            //遍历设置图片
            for (int i=0; i<imageList.count; i++) {
                NSDictionary * dic = imageList[i];
                ImageModel * image = [[ImageModel alloc] init];
                image.sub_url      = dic[@"sub_url"];
                image.url          = dic[@"url"];
                [imageModelList addObject:image];
            }
            self.imageView1.hidden = YES;
            self.imageView2.hidden = YES;
            self.imageView3.hidden = YES;
            NSArray * imageArr = @[self.imageView1, self.imageView2, self.imageView3];
            for (int i=0; i<imageModelList.count; i++) {
                ImageModel * image      = imageModelList[i];
                UIImageView * imageView = imageArr[i];
                imageView.hidden        = NO;
                [imageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:image.sub_url]] placeholderImage:[UIImage imageNamed:@"loading_default"]];
            }

        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//获取我创建的圈子
- (void)getCircles
{
    //getMyCircleList
    NSString * path = [kGetMyCircleListPath stringByAppendingFormat:@"?user_id=%ld", [UserService sharedService].user.uid];
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            NSArray * imageList = responseData[HttpResult];
            
            NSMutableArray * imageModelList = [[NSMutableArray alloc] init];
            //遍历设置图片
            for (int i=0; i<imageList.count; i++) {
                NSDictionary * dic = imageList[i];
                ImageModel * image = [[ImageModel alloc] init];
                image.sub_url      = dic[@"circle_cover_sub_image"];
                [imageModelList addObject:image];
            }
            self.circleImageView1.hidden = YES;
            self.circleImageView2.hidden = YES;
            self.circleImageView3.hidden = YES;
            NSArray * imageArr = @[self.circleImageView1, self.circleImageView2, self.circleImageView3];
            for (int i=0; i<imageModelList.count; i++) {
                ImageModel * image      = imageModelList[i];
                UIImageView * imageView = imageArr[i];
                imageView.hidden        = NO;
                [imageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:image.sub_url]] placeholderImage:[UIImage imageNamed:@"loading_default"]];
            }
            
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark- override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
