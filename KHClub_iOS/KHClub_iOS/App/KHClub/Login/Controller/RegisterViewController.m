//
//  RegisterViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/12.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "RegisterViewController.h"
#import "NSString+Encrypt.h"
#import "CusTabBarViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>

@interface RegisterViewController ()

//注册按钮
@property (nonatomic, strong) CustomButton * registerBtn;
//密码textfield
@property (nonatomic, strong) CustomTextField * passwordTextField;

@property (nonatomic, strong) CustomButton * reverifyBtn;
@property (nonatomic, strong) CustomTextField * verifyTextField;
//倒计时
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) int timerNum;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取验证码
    [self getVerify];
    
    self.timerNum = 20;
    
    [self createWidget];
    [self configUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (self.timer) {
        [self.timer invalidate];
    }
}

#pragma mark- override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.verifyTextField resignFirstResponder];    
    [self.passwordTextField resignFirstResponder];
}

#pragma mark- layout
- (void)createWidget
{
    //背景
    CustomImageView * backImageView = [[CustomImageView alloc] initWithFrame:self.view.bounds];
    backImageView.contentMode       = UIViewContentModeScaleAspectFill;
    backImageView.image             = [UIImage imageNamed:@"regist_login_bkgrnd"];
    [self.view addSubview:backImageView];
    [self.view sendSubviewToBack:backImageView];

    //验证码
    self.verifyTextField = [[CustomTextField alloc] init];
    //重新验证
    self.reverifyBtn     = [[CustomButton alloc] init];
    //注册
    self.registerBtn     = [[CustomButton alloc] init];
    //密码
    self.passwordTextField    = [[CustomTextField alloc] init];
    [self.view addSubview:self.registerBtn];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.verifyTextField];
    [self.view addSubview:self.reverifyBtn];
    
    [self.reverifyBtn addTarget:self action:@selector(resend:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerBtn addTarget:self action:@selector(verifyPress:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)configUI
{
    if (self.isFindPwd) {
        [self.navBar setNavTitle:KHClubString(@"Login_Register_ModifyPassword")];
    }else{
        [self.navBar setNavTitle:KHClubString(@"Login_Register_Title")];
    }
    
    //标题
    CustomLabel * textLabel                    = [[CustomLabel alloc] initWithFontSize:14];
    textLabel.textColor                        = [UIColor colorWithHexString:ColorDeepBlack];
    textLabel.frame                            = CGRectMake(kCenterOriginX(270), 130, 270, 20);
    textLabel.text                             = [NSString stringWithFormat:@"%@：%@" , KHClubString(@"Login_Register_VerificationSend"), self.phoneNumber];
    [self.view addSubview:textLabel];
    
    //placeHolder处理 验证textView
    UIFont * placeHolderFont1                  = [UIFont systemFontOfSize:FontLoginTextField];
    UIColor * placeHolderWhite1                = [UIColor colorWithHexString:ColorGary];
    NSAttributedString * placeHolderString1    = [[NSAttributedString alloc] initWithString:KHClubString(@"Login_Register_EnterVerification") attributes:@{NSFontAttributeName:placeHolderFont1,NSForegroundColorAttributeName:placeHolderWhite1}];
    //loginTextFiled样式处理
    self.verifyTextField.frame                 = CGRectMake(kCenterOriginX(270), textLabel.bottom+10, 200, 30);
    self.verifyTextField.delegate              = self;
    self.verifyTextField.attributedPlaceholder = placeHolderString1;
    self.verifyTextField.font                  = placeHolderFont1;
    self.verifyTextField.clearButtonMode       = UITextFieldViewModeWhileEditing;
    self.verifyTextField.textColor             = [UIColor colorWithHexString:ColorDeepBlack];
    self.verifyTextField.tintColor             = [UIColor colorWithHexString:ColorLightBlack];
    self.verifyTextField.keyboardType          = UIKeyboardTypeNumberPad;
    self.verifyTextField.backgroundColor       = [UIColor whiteColor];
    
    //重发按钮
    self.reverifyBtn.frame                     = CGRectMake(self.verifyTextField.right+5, self.verifyTextField.y, 65, self.verifyTextField.height);
    self.reverifyBtn.titleLabel.font           = [UIFont systemFontOfSize:FontLoginButton];
    self.reverifyBtn.layer.cornerRadius        = 2;
    [self.reverifyBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    self.reverifyBtn.enabled                   = NO;
    [self.reverifyBtn setTitle:@"20s" forState:UIControlStateNormal];
    [self.reverifyBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bkgrnd"] forState:UIControlStateNormal];
    
    //placeHolder处理
    UIFont * placeHolderFont                     = [UIFont systemFontOfSize:FontLoginTextField];
    UIColor * placeHolderWhite                   = [UIColor colorWithHexString:ColorGary];
    NSAttributedString * placeHolderString       = [[NSAttributedString alloc] initWithString:KHClubString(@"Login_SecondLogin_EnterPassword") attributes:@{NSFontAttributeName:placeHolderFont,NSForegroundColorAttributeName:placeHolderWhite}];
    //loginTextFiled样式处理
    self.passwordTextField.frame                 = CGRectMake(kCenterOriginX(270), self.verifyTextField.bottom+10, 270, 30);
    self.passwordTextField.delegate              = self;
    self.passwordTextField.secureTextEntry       = YES;
    self.passwordTextField.clearButtonMode       = UITextFieldViewModeWhileEditing;
    self.passwordTextField.attributedPlaceholder = placeHolderString;
    self.passwordTextField.font                  = placeHolderFont;
    self.passwordTextField.textColor             = [UIColor colorWithHexString:ColorDeepBlack];
    self.passwordTextField.tintColor             = [UIColor colorWithHexString:ColorLightBlack];
    self.passwordTextField.backgroundColor       = [UIColor whiteColor];

    CustomLabel * promptLabel                    = [[CustomLabel alloc] initWithFrame:CGRectMake(self.passwordTextField.x, self.passwordTextField.bottom+5, self.passwordTextField.width, 20)];
    promptLabel.text                             = KHClubString(@"Login_Register_PasswordLength");
    promptLabel.textAlignment                    = NSTextAlignmentCenter;
    promptLabel.textColor                        = [UIColor colorWithHexString:ColorBrown];
    promptLabel.font                             = [UIFont systemFontOfSize:10];
    [self.view addSubview:promptLabel];

    //btn样式处理
    self.registerBtn.frame                       = CGRectMake(kCenterOriginX(250), self.passwordTextField.bottom+40, 250, 30);
    self.registerBtn.layer.cornerRadius          = 3;
    [self.registerBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    self.registerBtn.fontSize                    = FontLoginButton;
    [self.registerBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bkgrnd"] forState:UIControlStateNormal];
    [self.registerBtn setTitle:StringCommonFinish forState:UIControlStateNormal];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerResend:) userInfo:nil repeats:YES];    
    
}

#pragma mark- event Response
- (void)verifyPress:(id)sender
{
    [self showLoading:KHClubString(@"Login_Login_WaitAMinute")];
    [SMS_SDK commitVerifyCode:self.verifyTextField.text result:^(enum SMS_ResponseState state) {

        if (1 == state) {

            if (self.isFindPwd) {
                [self findPwdLogin:nil];
            }else{
                [self registerLogin:nil];
            }

        }else {
            [self showWarn:KHClubString(@"Login_Register_VerificationError")];
        }
    }];
}

- (void)registerLogin:(id)sender
{
    
    if (self.passwordTextField.text.length < 6) {
        [self showWarn:KHClubString(@"Login_Register_PasswordLengthSix")];
        return;
    }
    
    debugLog(@"%@", kRegisterUserPath);
    NSDictionary * dic = @{@"username":self.phoneNumber,
                           @"password":[self.passwordTextField.text MD5]};
    [HttpService postWithUrlString:kRegisterUserPath params:dic andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        NSLog(@"%@", responseData);
        
        int status = [responseData[@"status"] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            //环信登录
            //异步登陆账号
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[ToolsManager getCommonTargetId:[UserService sharedService].user.uid]
                                                                password:IM_PWD
                                                              completion:
             ^(NSDictionary *loginInfo, EMError *error) {

                 
                 if (loginInfo && !error) {
                     
                     //设置是否自动登录
                     [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                     //获取数据库中数据
                     [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                     //获取群组列表
                     [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
                     //隐藏
                     [self hideLoading];
                     [self showComplete:KHClubString(@"Login_Register_RegisterSuccessful")];
                     [[[UserService sharedService] user] setModelWithDic:responseData[@"result"]];
                     //数据本地缓存
                     [[UserService sharedService] saveAndUpdate];
                     //找回密码成功进入主页
                     [CusTabBarViewController reinit];
                     CusTabBarViewController * ctbvc = [CusTabBarViewController sharedService];
                     UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:ctbvc];
                     
                     [self presentViewController:nav animated:YES completion:^{
                         //登录成功 出栈
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     }];
                     
                 }
                 else
                 {
                     //隐藏
                     [self hideLoading];
                     [self showWarn:StringCommonNetException];
                 }
             } onQueue:nil];
            
        }else{
            [self showWarn:StringCommonNetException];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

- (void)findPwdLogin:(id)sender
{
    
    if (self.passwordTextField.text.length < 6) {
        [self showWarn:KHClubString(@"Login_Register_PasswordLengthSix")];
        return;
    }
    
    debugLog(@"%@", kFindPwdPath);
    NSDictionary * dic = @{@"username":self.phoneNumber,
                           @"password":[self.passwordTextField.text MD5]};
    [HttpService postWithUrlString:kFindPwdPath params:dic andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        NSLog(@"%@", responseData);
        
        int status = [responseData[@"status"] intValue];
        if (status == HttpStatusCodeSuccess) {
            
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
                     
                     [self showComplete:KHClubString(@"Login_Register_PasswordModifySuccessful")];
                     [[[UserService sharedService] user] setModelWithDic:responseData[@"result"]];
                     //数据本地缓存
                     [[UserService sharedService] saveAndUpdate];
                     //找回密码成功进入主页
                     [CusTabBarViewController reinit];
                     CusTabBarViewController * ctbvc = [CusTabBarViewController sharedService];
                     UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:ctbvc];
                     [self presentViewController:nav animated:YES completion:^{
                         //登录成功 出栈
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     }];
                     
                 }
                 else
                 {
                     [self showWarn:StringCommonNetException];
                 }
             } onQueue:nil];
            
        }else{
            [self showWarn:StringCommonNetException];
        }
        
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

#pragma mark- UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark- private method
//获取验证码
- (void)getVerify
{
    if (self.areaNumber.length > 0) {
        self.areaNumber = [self.areaNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }else{
        self.areaNumber = @"86";
    }
    [SMS_SDK getVerificationCodeBySMSWithPhone:self.phoneNumber zone:self.areaNumber
                                        result:^(SMS_SDKError *error){
                                            
                                            //发送完毕隐藏
                                            if (!error)
                                            {
                                                [self showComplete:KHClubString(@"Login_Register_VerificationArrivied")];
                                            }
                                            else
                                            {
                                                [self showWarn:KHClubString(@"Login_Register_VerificationError")];
                                                [self.timer invalidate];
                                                //点击重发
                                                [self.reverifyBtn setTitle:[NSString stringWithFormat:KHClubString(@"Login_Register_Resend")] forState:UIControlStateNormal];
                                                self.reverifyBtn.enabled = YES;
                                            }
                                            
                                        }];
}

- (void)timerResend:(id)sender
{
    self.timerNum --;
    [self.reverifyBtn setTitle:[NSString stringWithFormat:@"%ds", self.timerNum] forState:UIControlStateNormal];
    
    if (self.timerNum == 0) {
        [self.timer invalidate];
        [self.reverifyBtn setTitle:[NSString stringWithFormat:KHClubString(@"Login_Register_Resend")] forState:UIControlStateNormal];
        self.reverifyBtn.enabled = YES;
        return;
    }
    
}

- (void)resend:(id)sender
{
    [self showLoading:StringCommonDownloadData];
    //获取验证码
    [self getVerify];
    self.timerNum = 20;
    self.reverifyBtn.enabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerResend:) userInfo:nil repeats:YES];
    
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
