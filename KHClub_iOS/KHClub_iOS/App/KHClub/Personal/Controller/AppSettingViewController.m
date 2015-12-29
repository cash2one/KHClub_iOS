//
//  AppSettingViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "AppSettingViewController.h"
#import "ApplyViewController.h"
#import "SDWebImageManager.h"
#import "HttpCache.h"

@interface AppSettingViewController ()

//背景滚动视图
@property (nonatomic, strong) UIScrollView * backScrollView;

@end

@implementation AppSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)initUI
{
    [self setNavBarTitle:KHClubString(@"Personal_AppSetting_Title")];
    self.backScrollView                              = [[UIScrollView alloc] init];
    self.backScrollView.frame                        = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;
    self.backScrollView.contentSize                  = CGSizeMake(0, self.backScrollView.height+1);
    [self.view addSubview:self.backScrollView];
    
    //背景
    CustomButton * cacheBackView  = [[CustomButton alloc] initWithFrame:CGRectMake(0, 20, self.viewWidth, 50)];
    cacheBackView.backgroundColor = [UIColor whiteColor];
    //标题
    CustomLabel * cacheTitleLabel = [[CustomLabel alloc] initWithFontSize:15];
    cacheTitleLabel.frame         = CGRectMake(15, 10, 170, 30);
    cacheTitleLabel.textColor     = [UIColor colorWithHexString:ColorCharGary];
    cacheTitleLabel.text          = KHClubString(@"Personal_AppSetting_Clear");
    UIView * lineView             = [[UIView alloc] initWithFrame:CGRectMake(0, cacheBackView.height-1, cacheBackView.width, 1)];
    lineView.backgroundColor      = [UIColor colorWithHexString:ColorLightGary];
    [cacheBackView addSubview:lineView];
    [cacheBackView addSubview:cacheTitleLabel];
    [self.backScrollView addSubview:cacheBackView];
    [cacheBackView addTarget:self action:@selector(cacheClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //退出登录
    CustomButton * logoutBtn  = [[CustomButton alloc] init];
    logoutBtn.frame           = CGRectMake(kCenterOriginX(300), 40+cacheBackView.bottom, 300, 45);
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [logoutBtn setBackgroundImage:[UIImage imageNamed:@"logout_btn"] forState:UIControlStateNormal];
    [logoutBtn setTitle:KHClubString(@"Personal_AppSetting_Logout") forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:logoutBtn];
    
}

- (void)cacheClick:(id)sender
{
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache clearDisk];
    [HttpCache clearDisk];
    [self showHint:KHClubString(@"Personal_AppSetting_ClearOK")];
}

- (void)logout:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:KHClubString(@"Personal_AppSetting_LogoutPrompt") message:@"" delegate:self cancelButtonTitle:StringCommonCancel otherButtonTitles:StringCommonConfirm, nil];
    [alert show];

}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self logout];
    }
}

#pragma mark- private method
- (void)logout
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [weakSelf hideHud];
        if (error && error.errorCode != EMErrorServerNotLogin) {
            [weakSelf showHint:error.description];
        }
        else{
            [[ApplyViewController shareController] clear];
            //清空
            [[UserService sharedService] clear];
            [[PushService sharedInstance] logout];
            //进入登录页
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ENTER_LOGIN object:nil];
        }
    } onQueue:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
