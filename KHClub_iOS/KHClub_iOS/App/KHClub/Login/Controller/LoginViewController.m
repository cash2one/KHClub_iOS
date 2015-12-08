//
//  LoginViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/12.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "SecondLoginViewController.h"
#import "WebViewController.h"

@interface LoginViewController ()

@property(nonatomic, strong) CustomButton * loginBtn;
@property(nonatomic, strong) CustomTextField * loginTextField;
//免责声明
@property(nonatomic, strong) CustomButton * protocolBtn;
//area选择
@property(nonatomic, strong) CustomButton * areaBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHexString:ColorGold];
    
    //自动登录
    if ([self autoLogin]) {
        return;
    }else{
        //非自动登录 初始化页面
        [self createWidget];
        [self configUI];
    }
}

#pragma mark- layout
- (void)createWidget
{
    //背景
    CustomImageView * backImageView = [[CustomImageView alloc] initWithFrame:self.view.bounds];
    backImageView.contentMode       = UIViewContentModeScaleAspectFill;
    backImageView.image             = [UIImage imageNamed:@"regist_login_bkgrnd"];
    [self.view addSubview:backImageView];
    //登录按钮
    self.loginBtn       = [[CustomButton alloc] init];
    //登录textfield
    self.loginTextField = [[CustomTextField alloc] init];
    //用户协议
    self.protocolBtn    = [[CustomButton alloc] init];
    //区域选择
    self.areaBtn        = [[CustomButton alloc] init];
    
    [self.view addSubview:self.loginBtn];
    [self.view addSubview:self.loginTextField];
    [self.view addSubview:self.protocolBtn];
    [self.view addSubview:self.areaBtn];
    
    //绑定事件
    [self.loginBtn addTarget:self action:@selector(nextLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.protocolBtn addTarget:self action:@selector(userProtocolPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.areaBtn addTarget:self action:@selector(areaPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configUI
{
    self.areaBtn.frame                        = CGRectMake(kCenterOriginX(270), 150, 40, 30);
    self.areaBtn.backgroundColor              = [UIColor whiteColor];
    self.areaBtn.titleLabel.font              = [UIFont systemFontOfSize:FontLoginTextField];
    [self.areaBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];
    [self.areaBtn setTitle:@"+86" forState:UIControlStateNormal];
    
    //placeHolder处理
    UIFont * placeHolderFont                  = [UIFont systemFontOfSize:FontLoginTextField];
    UIColor * placeHolderWhite                = [UIColor colorWithHexString:ColorGary];
    NSAttributedString * placeHolderString    = [[NSAttributedString alloc] initWithString:KHClubString(@"Login_Login_EnterPrompt") attributes:@{NSFontAttributeName:placeHolderFont,NSForegroundColorAttributeName:placeHolderWhite}];
    //loginTextFiled样式处理
    self.loginTextField.frame                 = CGRectMake(kCenterOriginX(270)+50, 150, 220, 30);
    self.loginTextField.delegate              = self;
    self.loginTextField.attributedPlaceholder = placeHolderString;
    self.loginTextField.font                  = placeHolderFont;
    self.loginTextField.clearButtonMode       = UITextFieldViewModeWhileEditing;
    self.loginTextField.textColor             = [UIColor colorWithHexString:ColorDeepBlack];
    self.loginTextField.tintColor             = [UIColor colorWithHexString:ColorLightBlack];
    self.loginTextField.keyboardType          = UIKeyboardTypeNumberPad;
    self.loginTextField.backgroundColor       = [UIColor whiteColor];

    //btn样式处理
    self.loginBtn.frame                       = CGRectMake(kCenterOriginX(270), self.loginTextField.bottom+30, 270, 40);
    self.loginBtn.layer.cornerRadius          = 3;
    [self.loginBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    self.loginBtn.fontSize                    = FontLoginButton;
    [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bkgrnd"] forState:UIControlStateNormal];
    [self.loginBtn setTitle:KHClubString(@"Login_Login_LoginOrRegister") forState:UIControlStateNormal];

    //用户协议
    self.protocolBtn.frame                    = CGRectMake(kCenterOriginX(280), self.view.bottom-50, 280, 40);
    self.protocolBtn.fontSize                 = 13;
    self.protocolBtn.titleLabel.textColor     = [UIColor whiteColor];
    NSMutableAttributedString * protocolStr   = [[NSMutableAttributedString alloc] initWithString:KHClubString(@"Login_Login_Protocol")];
    [self.protocolBtn setAttributedTitle:protocolStr forState:UIControlStateNormal];
}

#pragma mark- event Response
- (void)areaPress:(id)sender
{
    UIAlertView * areaAlert = [[UIAlertView alloc] initWithTitle:KHClubString(@"Login_Register_AreaCode") message:nil delegate:self cancelButtonTitle:StringCommonCancel otherButtonTitles:@"中国大陆 +86",@"Singapore +65", nil];
    [areaAlert show];
}

- (void)nextLogin:(id)sender
{

    if (self.loginTextField.text.length < 1) {
        [self showWarn:KHClubString(@"Login_Login_UsernameNotNull")];
        return;
    }
    
    [self showLoading:nil];
    NSDictionary * params = @{@"username":self.loginTextField.text};
    debugLog(@"%@ %@", kIsUserPath, params);
    [HttpService postWithUrlString:kIsUserPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        //登录
        int loginDirection    = 1;
        //注册
        int registerDirection = 2;
        int status = [responseData[@"status"] intValue];
        if (status == HttpStatusCodeSuccess) {
            int direction = [responseData[@"result"][@"direction"] intValue];
            if (direction == loginDirection) {
                [self hideLoading];
                SecondLoginViewController * slVC = [[SecondLoginViewController alloc] init];
                slVC.username                    = self.loginTextField.text;
                slVC.areaCode                    = self.areaBtn.titleLabel.text;
                [self pushVC:slVC];
            }
            
            if (direction == registerDirection) {
                RegisterViewController * rvc = [[RegisterViewController alloc] init];
                rvc.phoneNumber              = self.loginTextField.text;
                rvc.areaNumber               = self.areaBtn.titleLabel.text;
                [self pushVC:rvc];
                [self hideLoading];
            }
            
        }else{
            [self showWarn:StringCommonNetException];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];

}

#pragma mark- override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.loginTextField resignFirstResponder];
}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self.areaBtn setTitle:@"+86" forState:UIControlStateNormal];
            break;
        case 2:
            [self.areaBtn setTitle:@"+65" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.loginTextField resignFirstResponder];
    return YES;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    //手机号不超过11位
//    if (range.length == 0) {
//        if ((textField.text.length+string.length)>11) {
//            return NO;
//        }
//    }
//    
//    return YES;
//}
#pragma mark- method response
- (void)userProtocolPress:(id)sender
{
    WebViewController * wvc = [[WebViewController alloc] init];
    wvc.webURL              = [NSURL URLWithString:kUserProtocolPath];
    [self pushVC:wvc];
}

#pragma mark- privateMethod

//自动登录
- (BOOL)autoLogin
{
    [[UserService sharedService] find];
    
    //环信自动登录
    BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
    
    //如果用户登录过 自动登录
    if (isAutoLogin && [UserService sharedService].user.uid > 0 && [UserService sharedService].user.login_token.length > 0) {
        
        //登录成功进入主页
        CusTabBarViewController * ctbvc = [CusTabBarViewController sharedService];
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:ctbvc];

        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:nav animated:NO completion:^{
            //自动登录成功 初始化这个页面
            [self createWidget];
            [self configUI];
        }];
        
        return YES;
    }
    
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
