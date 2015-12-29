//
//  SecondLoginViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/13.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "SecondLoginViewController.h"
#import "NSString+Encrypt.h"
#import "AppDelegate.h"
#import "CusTabBarViewController.h"
#import "RegisterViewController.h"
#import "RegisterViewController.h"

@interface SecondLoginViewController ()

//密码
@property(nonatomic, strong) CustomTextField * passwordTextField;
//登录
@property(nonatomic, strong) CustomButton * loginBtn;
//找回密码
@property(nonatomic, strong) CustomButton * findPwdBtn;


@end

@implementation SecondLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWidget];
    [self configUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)initWidget
{
    //背景
    CustomImageView * backImageView = [[CustomImageView alloc] initWithFrame:self.view.bounds];
    backImageView.contentMode       = UIViewContentModeScaleAspectFill;
    backImageView.image             = [UIImage imageNamed:@"regist_login_bkgrnd"];
    [self.view addSubview:backImageView];
    [self.view sendSubviewToBack:backImageView];
    
    //登录按钮
    self.loginBtn          = [[CustomButton alloc] init];
    //密码textfield
    self.passwordTextField = [[CustomTextField alloc] init];
    self.findPwdBtn        = [[CustomButton alloc] init];
    
    [self.view addSubview:self.loginBtn];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.findPwdBtn];
    
    //设置事件
    [self.loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.findPwdBtn addTarget:self action:@selector(forgetPwd:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configUI
{
    [self.navBar setNavTitle:KHClubString(@"Login_SecondLogin_Title")];
    
    //placeHolder处理
    UIFont * placeHolderFont                  = [UIFont systemFontOfSize:FontLoginTextField];
    UIColor * placeHolderWhite                = [UIColor colorWithHexString:ColorGary];
    NSAttributedString * placeHolderString    = [[NSAttributedString alloc] initWithString:KHClubString(@"Login_SecondLogin_EnterPassword") attributes:@{NSFontAttributeName:placeHolderFont,NSForegroundColorAttributeName:placeHolderWhite}];
    //loginTextFiled样式处理
    self.passwordTextField.frame                 = CGRectMake(kCenterOriginX(250), 150, 250, 30);
    self.passwordTextField.delegate              = self;
    self.passwordTextField.secureTextEntry       = YES;
    self.passwordTextField.clearButtonMode       = UITextFieldViewModeWhileEditing;
    self.passwordTextField.attributedPlaceholder = placeHolderString;
    self.passwordTextField.font                  = placeHolderFont;
    self.passwordTextField.textColor             = [UIColor colorWithHexString:ColorDeepBlack];
    self.passwordTextField.tintColor             = [UIColor colorWithHexString:ColorLightBlack];
    self.passwordTextField.backgroundColor       = [UIColor colorWithHexString:ColorWhite];

    //btn样式处理
    self.loginBtn.frame                          = CGRectMake(kCenterOriginX(250), self.passwordTextField.bottom+30, 250, 30);
    self.loginBtn.layer.cornerRadius             = 3;
    [self.loginBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    self.loginBtn.fontSize                       = FontLoginButton;
    self.loginBtn.backgroundColor                = [UIColor colorWithHexString:ColorGold];
    [self.loginBtn setTitle:StringCommonFinish forState:UIControlStateNormal];

    //找回密码
    self.findPwdBtn.frame                        = CGRectMake(kCenterOriginX(120), self.view.bottom-50, 120, 40);
    self.findPwdBtn.fontSize                     = 13;
    [self.findPwdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.findPwdBtn setTitle:KHClubString(@"Login_SecondLogin_ForgotPassword") forState:UIControlStateNormal];
}

#pragma mark- override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.passwordTextField resignFirstResponder];
}

#pragma mark- method response
- (void)loginClick:(id)sender {
    
    if (self.passwordTextField.text.length < 6) {
        ALERT_SHOW(StringCommonPrompt, KHClubString(@"Login_Register_PasswordLengthSix"));
        return;
    }

    debugLog(@"%@", kLoginUserPath);
    NSDictionary * dic = @{@"username":self.username,
                           @"password":[self.passwordTextField.text MD5]};
    debugLog(@"%@", dic);
    [self showLoading:KHClubString(@"Login_SecondLogin_Loginning")];
    [HttpService postWithUrlString:kLoginUserPath params:dic andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[@"status"] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            //数据注入
            [[[UserService sharedService] user] setModelWithDic:responseData[@"result"]];
            //环信登录
            //异步登陆账号
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[ToolsManager getCommonTargetId:[UserService sharedService].user.uid]
                                                                password:IM_PWD
                                                              completion:
             ^(NSDictionary *loginInfo, EMError *error) {
                 //隐藏
                 [self hideLoading];
                 
                 if (loginInfo && !error) {
                     //设置是否自动登录
                     [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                     //获取数据库中数据
                     [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                     //获取群组列表
                     [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
                     //数据本地缓存
                     [[UserService sharedService] saveAndUpdate];
                     //进入主页
                     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ENTER_MAIN object:nil];
                     
                 }
                 else
                 {
                     [self showWarn:StringCommonNetException];
//                     switch (error.errorCode)
//                     {
//                         case EMErrorNotFound:
//                             TTAlertNoTitle(error.description);
//                             break;
//                         case EMErrorNetworkNotConnected:
//                             TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
//                             break;
//                         case EMErrorServerNotReachable:
//                             TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
//                             break;
//                         case EMErrorServerAuthenticationFailure:
//                             TTAlertNoTitle(error.description);
//                             break;
//                         case EMErrorServerTimeout:
//                             TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
//                             break;
//                         default:
//                             TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
//                             break;
//                     }
                 }
             } onQueue:nil];

        }else{
            [self showWarn:KHClubString(@"Login_SecondLogin_UsernameOrPasswordError")];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

- (void)forgetPwd:(id)sender {
    
    //忘记密码
    RegisterViewController * vvc = [[RegisterViewController alloc] init];
    vvc.phoneNumber            = self.username;
    vvc.isFindPwd              = YES;
    [self pushVC:vvc];
    
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.passwordTextField resignFirstResponder];
    return YES;
}


#pragma mark- private Method
//跳转到找回密码页面 发送验证码

@end
