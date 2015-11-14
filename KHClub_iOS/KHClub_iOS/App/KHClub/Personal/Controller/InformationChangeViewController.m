//
//  InformationChangeViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/22.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "InformationChangeViewController.h"

@interface InformationChangeViewController ()

@property (nonatomic, strong) CustomTextField * nameTextFiled;
@property (nonatomic, strong) PlaceHolderTextView * signTextView;
@property (nonatomic, strong) UISwitch * switchView;

@end

@implementation InformationChangeViewController
{
    ChangeBlock _changeBlock;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];
    
    [self.navBar.rightBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    [self.navBar.rightBtn setTitleColor:[UIColor colorWithHexString:ColorDeepGary] forState:UIControlStateHighlighted];

    switch (self.changeType) {
        case ChangePersonalName:
        case ChangePersonalPhone:
        case ChangePersonalJob:
        case ChangePersonalCompany:
        case ChangePersonalEmail:
            [self createShortUI];
            break;
        case ChangePersonalSign:
        case ChangePersonalAddress:
            [self createLongUI];
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
/**
 *  短UI
 */
- (void)createShortUI
{
    __block typeof(_changeBlock) ccblock = _changeBlock;
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:StringCommonSave andBlock:^{
        
        if (self.changeType == ChangePersonalName) {
            if (sself.nameTextFiled.text.length < 1) {
                [sself showWarn:KHClubString(@"Personal_PersonalSetting_NameNotNull")];
                return ;
            }
            if (sself.nameTextFiled.text.length>64) {
                [sself showWarn:KHClubString(@"Personal_PersonalSetting_NameTooLong")];
                return ;
            }
        }else{
            if (sself.nameTextFiled.text.length>40) {
                [sself showWarn:KHClubString(@"Personal_PersonalSetting_TooLong")];
                return ;
            }
        }
        
        if (ccblock) {
            
            //地址传送状态
            if (self.changeType == ChangePersonalPhone || self.changeType == ChangePersonalEmail) {
                ccblock(sself.nameTextFiled.text,sself.switchView.on);
            }else{
                ccblock(sself.nameTextFiled.text, 1);
            }
        }
        [sself.navigationController popViewControllerAnimated:YES];
    }];
    
    CustomImageView * backImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(kCenterOriginX(300), kNavBarAndStatusHeight+20, 300, 30)];
    backImageView.image             = [UIImage imageNamed:@"comment_border_view"];
    [self.view addSubview:backImageView];

    self.nameTextFiled              = [[CustomTextField alloc] initWithFrame:CGRectMake(kCenterOriginX(290), kNavBarAndStatusHeight+20, 290, 30)];
    self.nameTextFiled.font         = [UIFont systemFontOfSize:14];
    self.nameTextFiled.textColor    = [UIColor colorWithHexString:ColorDeepBlack];
    
    UserModel * user = [UserService sharedService].user;
    switch (self.changeType) {
        case ChangePersonalName:
            [self setNavBarTitle:KHClubString(@"Personal_PersonalSetting_Name")];
            self.nameTextFiled.placeholder = KHClubString(@"Personal_PersonalSetting_EnterName");
            self.nameTextFiled.text = user.name;
            break;
        case ChangePersonalPhone:
            [self setNavBarTitle:KHClubString(@"Personal_PersonalSetting_Phone")];
            self.nameTextFiled.placeholder = KHClubString(@"Personal_PersonalSetting_EnterPhone");
            self.nameTextFiled.text = user.phone_num;
            [self setStateView];
            break;
        case ChangePersonalJob:
            [self setNavBarTitle:KHClubString(@"Personal_PersonalSetting_Job")];
            self.nameTextFiled.placeholder = KHClubString(@"Personal_PersonalSetting_EnterJob");
            self.nameTextFiled.text = user.job;
            break;
        case ChangePersonalCompany:
            [self setNavBarTitle:KHClubString(@"Personal_PersonalSetting_Company")];
            self.nameTextFiled.placeholder = KHClubString(@"Personal_PersonalSetting_EnterCompany");
            self.nameTextFiled.text = user.company_name;
            break;
        case ChangePersonalEmail:
            [self setNavBarTitle:KHClubString(@"Personal_PersonalSetting_Email")];
            self.nameTextFiled.placeholder = KHClubString(@"Personal_PersonalSetting_EnterEmail");
            self.nameTextFiled.text = user.e_mail;
            [self setStateView];
            break;
        default:
            break;
    }
    
    [self.view addSubview:self.nameTextFiled];
}

/**
 *  长UI
 */
- (void)createLongUI
{
    __block typeof(_changeBlock) ccblock = _changeBlock;
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:StringCommonSave andBlock:^{
        
        if (sself.signTextView.text.length > 50) {
            [sself showWarn:KHClubString(@"Personal_PersonalSetting_TooLong")];
            return ;
        }
        if (ccblock) {
            //地址传送状态
            if (self.changeType == ChangePersonalAddress) {
                ccblock(sself.signTextView.text,sself.switchView.on);
            }else{
                ccblock(sself.signTextView.text,1);
            }
        }
        [sself.navigationController popViewControllerAnimated:YES];
    }];
    
    CustomImageView * backImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(kCenterOriginX(300), kNavBarAndStatusHeight+20, 300, 80)];
    backImageView.image             = [UIImage imageNamed:@"comment_border_view"];
    [self.view addSubview:backImageView];
    
    UserModel * user = [UserService sharedService].user;
    switch (self.changeType) {
        case ChangePersonalSign:
            [self setNavBarTitle:KHClubString(@"Personal_Personal_Sign")];
            self.signTextView               = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(kCenterOriginX(300), kNavBarAndStatusHeight+20, 300, 80) andPlaceHolder:KHClubString(@"Personal_PersonalSetting_EnterSign")];
            self.signTextView.text          = user.signature;
            break;
        case ChangePersonalAddress:
            [self setNavBarTitle:KHClubString(@"Personal_PersonalSetting_Address")];
            self.signTextView               = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(kCenterOriginX(300), kNavBarAndStatusHeight+20, 300, 80) andPlaceHolder:KHClubString(@"Personal_PersonalSetting_EnterAddress")];
            self.signTextView.text          = user.address;
            [self setStateView];
            break;
        default:
            break;
    }
    
    self.signTextView.font          = [UIFont systemFontOfSize:14];
    self.signTextView.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    [self.view addSubview:self.signTextView];
}


#pragma mark- private method
- (void)setChangeBlock:(ChangeBlock)block
{
    _changeBlock = [block copy];
}

//有隐藏状态的
- (void)setStateView
{
    CustomLabel * stateLabel = [[CustomLabel alloc] initWithFontSize:16];
    stateLabel.textColor     = [UIColor colorWithHexString:ColorLightBlack];
    stateLabel.text          = KHClubString(@"Personal_PersonalSetting_FriendsCanSee");
    stateLabel.textAlignment = NSTextAlignmentRight;
    
    
    self.switchView = [[UISwitch alloc] init];
    [self.view addSubview:stateLabel];
    [self.view addSubview:self.switchView];
    
    switch (self.changeType) {
        case ChangePersonalPhone:
            self.switchView.frame = CGRectMake(self.viewWidth-70, self.nameTextFiled.bottom+10, 30, 20);
            stateLabel.frame      = CGRectMake(self.switchView.x-200, self.switchView.y+5, 190, 20);
            if ([UserService sharedService].user.phone_state == SeeOnlyFriends) {
                [self.switchView setOn:YES];
            }else{
                [self.switchView setOn:NO];
            }
            break;
        case ChangePersonalEmail:
            self.switchView.frame = CGRectMake(self.viewWidth-70, self.nameTextFiled.bottom+10, 30, 20);
            stateLabel.frame      = CGRectMake(self.switchView.x-200, self.switchView.y+5, 190, 20);
            if ([UserService sharedService].user.email_state == SeeOnlyFriends) {
                [self.switchView setOn:YES];
            }else{
                [self.switchView setOn:NO];
            }
            break;
        case ChangePersonalAddress:
            self.switchView.frame = CGRectMake(self.viewWidth-70, self.signTextView.bottom+10, 30, 20);
            stateLabel.frame      = CGRectMake(self.switchView.x-200, self.switchView.y+5, 190, 20);
            if ([UserService sharedService].user.phone_state == SeeOnlyFriends) {
                [self.switchView setOn:YES];
            }else{
                [self.switchView setOn:NO];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark- override
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nameTextFiled resignFirstResponder];
    [self.signTextView resignFirstResponder];
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
