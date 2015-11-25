//
//  PersonalSettingViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/4.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "PersonalSettingViewController.h"
#import "UIImageView+WebCache.h"
#import "NSData+ImageCache.h"
#import "InformationChangeViewController.h"
#import "AppSettingViewController.h"

@interface PersonalSettingViewController ()

//背景滚动视图
@property (nonatomic, strong) UIScrollView * backScrollView;
//头像
@property (nonatomic, strong) CustomImageView * headImageView;
//名字
@property (nonatomic, strong) CustomLabel * nameLabel;
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
//性别
@property (nonatomic, strong) CustomLabel * sexLabel;
//签名
@property (nonatomic, strong) CustomLabel * signLabel;
////标签1
//@property (nonatomic, strong) CustomLabel * titleLabel1;
////标签2
//@property (nonatomic, strong) CustomLabel * titleLabel2;
////标签3
//@property (nonatomic, strong) CustomLabel * titleLabel3;

@property (nonatomic, strong) NSUserDefaults * defaults;

@end

@implementation PersonalSettingViewController

//#define Title_1_Key @"title_1"
//#define Title_2_Key @"title_2"
//#define Title_3_Key @"title_3"

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWidget];
    [self configUI];
    [self setData];
//    [self getExtraInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- private method
- (void)initWidget
{
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    self.backScrollView = [[UIScrollView alloc] init];
    self.headImageView  = [[CustomImageView alloc] init];
    
    [self.view addSubview:self.backScrollView];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:@"" andBlock:^{
        AppSettingViewController * asvc = [[AppSettingViewController alloc] init];
        [sself pushVC:asvc];
    }];
}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"Personal_PersonalSetting_Setting")];
    self.backScrollView.frame = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;
    
    //最顶部头像
    CustomButton * backView    = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 80)];
    backView.tag               = 1;
    backView.backgroundColor   = [UIColor whiteColor];
    CustomLabel * titleLabel   = [[CustomLabel alloc] initWithFontSize:15];
    titleLabel.frame           = CGRectMake(15, 10, 70, 60);
    titleLabel.textColor       = [UIColor colorWithHexString:ColorCharGary];
    titleLabel.text            = KHClubString(@"Personal_PersonalSetting_Icon");
    self.headImageView.frame   = CGRectMake(self.viewWidth-75, 10, 60, 60);
    UIView * lineView          = [[UIView alloc] initWithFrame:CGRectMake(0, backView.height-1, backView.width, 1)];
    lineView.backgroundColor   = [UIColor colorWithHexString:ColorLightGary];
    [backView addSubview:self.headImageView];
    [backView addSubview:lineView];
    [backView addSubview:titleLabel];
    [backView addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backScrollView addSubview:backView];
    
    //姓名
    self.nameLabel    = [self setCommonCellWith:KHClubString(@"Personal_PersonalSetting_Name") andFrame:CGRectMake(0, 80, self.viewWidth, 50) tag:2];
    //职位
    self.jobLabel     = [self setCommonCellWith:KHClubString(@"Personal_PersonalSetting_Job") andFrame:CGRectMake(0, 80+50, self.viewWidth, 50) tag:3];
    //公司
    self.companyLabel = [self setCommonCellWith:KHClubString(@"Personal_PersonalSetting_Company") andFrame:CGRectMake(0, 80+50*2, self.viewWidth, 50) tag:4];
    //地址
    self.addressLabel = [self setCommonCellWith:KHClubString(@"Personal_PersonalSetting_Address") andFrame:CGRectMake(0, 80+50*3, self.viewWidth, 50) tag:5];
    //性别
    self.sexLabel     = [self setCommonCellWith:KHClubString(@"Personal_PersonalSetting_Sex") andFrame:CGRectMake(0, 80+50*4, self.viewWidth, 50) tag:6];
    
    //邮箱
    self.emailLabel   = [self setCommonCellWith:KHClubString(@"Personal_PersonalSetting_Email") andFrame:CGRectMake(0, 80+15+50*5, self.viewWidth, 50) tag:7];
    //电话
    self.phoneLabel   = [self setCommonCellWith:KHClubString(@"Personal_PersonalSetting_Phone") andFrame:CGRectMake(0, 80+15+50*6, self.viewWidth, 50) tag:8];
    //签名
    self.signLabel    = [self setCommonCellWith:KHClubString(@"Personal_Personal_Sign") andFrame:CGRectMake(0, 80+15+50*7, self.viewWidth, 50) tag:9];
//    //头衔部分
//    [self setTitlePart];
    
    self.navBar.rightBtn.imageEdgeInsets       = UIEdgeInsetsMake(12, 26, 12, 0);
    self.navBar.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //设置
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"personal_setting"] forState:UIControlStateNormal];
    
    self.backScrollView.contentSize = CGSizeMake(0, self.backScrollView.height+1);
}

//#define Title1Tag 11
//#define Title2Tag 12
//#define Title3Tag 13

//- (void)setTitlePart
//{
//    //头衔部分
//    CustomButton * titleBackView  = [[CustomButton alloc] initWithFrame:CGRectMake(0, 100+15+50*8, self.viewWidth, 50)];
//    titleBackView.backgroundColor = [UIColor whiteColor];
//    CustomLabel * messageLabel1   = [[CustomLabel alloc] initWithFrame:CGRectMake(15, 10, 70, 30)];
//    messageLabel1.textColor       = [UIColor colorWithHexString:ColorCharGary];
//    messageLabel1.font            = [UIFont systemFontOfSize:14];
//    messageLabel1.text            = @"个人头衔";
//    CustomLabel * messageLabel2   = [[CustomLabel alloc] initWithFrame:CGRectMake(self.viewWidth-250, 10, 240, 30)];
//    messageLabel2.textAlignment   = NSTextAlignmentRight;
//    messageLabel2.textColor       = [UIColor colorWithHexString:ColorCharGary];
//    messageLabel2.font            = [UIFont systemFontOfSize:14];
//    messageLabel2.text            = @"请介绍您更多的身份（10个字以内）";
//    UIView * lineView             = [[UIView alloc] initWithFrame:CGRectMake(0, titleBackView.height-1, titleBackView.width, 1)];
//    lineView.backgroundColor      = [UIColor colorWithHexString:ColorLightGary];
//    [titleBackView addSubview:lineView];
//    [titleBackView addSubview:messageLabel1];
//    [titleBackView addSubview:messageLabel2];
//    [self.backScrollView addSubview:titleBackView];
//    
//    //邮箱
//    self.titleLabel1                = [self setCommonTitleCellFrame:CGRectMake(0, titleBackView.bottom, self.viewWidth, 50) tag:Title1Tag];
//    //电话
//    self.titleLabel2                = [self setCommonTitleCellFrame:CGRectMake(0, titleBackView.bottom+50, self.viewWidth, 50) tag:Title2Tag];
//    //签名
//    self.titleLabel3                = [self setCommonTitleCellFrame:CGRectMake(0, titleBackView.bottom+50*2, self.viewWidth, 50) tag:Title3Tag];
//
//    self.backScrollView.contentSize = CGSizeMake(0, titleBackView.bottom+50*2+80);
//
//    self.titleLabel1.text           = [ToolsManager emptyReturnNone:[self.defaults objectForKey:Title_1_Key]];
//    self.titleLabel2.text           = [ToolsManager emptyReturnNone:[self.defaults objectForKey:Title_2_Key]];
//    self.titleLabel3.text           = [ToolsManager emptyReturnNone:[self.defaults objectForKey:Title_3_Key]];
//    
//}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 2) {
        return;
    }

    NSString * sexStr = @"0";
    if (buttonIndex == SexMale) {
        self.sexLabel.text = KHClubString(@"Personal_PersonalSetting_Man");
        sexStr = @"0";
    }else{
        self.sexLabel.text = KHClubString(@"Personal_PersonalSetting_Woman");
        sexStr = @"1";
    }
    [self updateDataInformationWithField:@"sex" andValue:sexStr];

}

#pragma mark- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //选照片
    if (buttonIndex != 2) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        //如果是头像 则裁剪
        picker.allowsEditing = YES;
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            }
        }
        if (buttonIndex == 1) {
            [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image;
    image = [ImageHelper getBigImage:info[UIImagePickerControllerEditedImage]];
    
    [self imageUploadWithImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- event response
- (void)settingClick:(CustomButton *)btn
{
    
    switch (btn.tag) {
        case 1:
            //头像
            [self headImageClick];
            break;
        case 2:
            //姓名
            [self infoChangeWith:ChangePersonalName];
            break;
        case 3:
            //职位
            [self infoChangeWith:ChangePersonalJob];
            break;
        case 4:
            //公司
            [self infoChangeWith:ChangePersonalCompany];
            break;
        case 5:
            //地址
            [self infoChangeWith:ChangePersonalAddress];
            break;
        case 6:
            //性别
            [self sexClick];
            break;
        case 7:
            //邮箱
            [self infoChangeWith:ChangePersonalEmail];
            break;
        case 8:
            //电话
            [self infoChangeWith:ChangePersonalPhone];
            break;
        case 9:
            //签名
            [self infoChangeWith:ChangePersonalSign];
            break;
//            //标签
//        case Title1Tag:
//            [self infoChangeWith:ChangePersonalTitle1];
//            break;
//        case Title2Tag:
//            [self infoChangeWith:ChangePersonalTitle2];
//            break;
//        case Title3Tag:
//            [self infoChangeWith:ChangePersonalTitle3];
//            break;
        default:
            break;
    }
}

#pragma mark- private method
- (void)imageUploadWithImage:(UIImage *)image
{
    
    NSDictionary * params = @{@"uid":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"field":@"head_image"};
    NSString * fileName;
    NSArray * files;
    
    //头像处理或者背景
    if (image != nil) {
        fileName = [ToolsManager getUploadImageName];
        files = @[@{FileDataKey:UIImageJPEGRepresentation(image,0.9),FileNameKey:fileName}];
    }
    
    debugLog(@"%@ %@", kChangeInformationImagePath, params);
    [self showLoading:nil];
    [HttpService postFileWithUrlString:kChangeInformationImagePath params:params files:files andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        //        debugLog(@"%@", responseData);
        int status = [responseData[@"status"] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            NSString * path = responseData[@"result"][@"image"];
            [self hideLoading];
            [UserService sharedService].user.head_image     = path;
            [UserService sharedService].user.head_sub_image = responseData[@"result"][@"subimage"];
            //缓存头像
            [UIImageJPEGRepresentation(image, 0.9) cacheImageWithUrl:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, [UserService sharedService].user.head_image]];
            //设置图片
            [self.headImageView setImage:image];
            
            //数据缓存
            [[UserService sharedService] saveAndUpdate];
            
        }else{
            [self showWarn:StringCommonNetException];
        }
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

//上传用户信息
- (void)updateDataInformationWithField:(NSString *)field andValue:(NSString *)value
{
    NSDictionary * params = @{@"uid":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"field":field,
                              @"value":value};
    
    debugLog(@"%@ %@", kChangePersonalInformationPath, params);
    [HttpService postWithUrlString:kChangePersonalInformationPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [[UserService sharedService].user setValue:value forKey:field];
            //数据缓存
            [[UserService sharedService] saveAndUpdate];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//上传用户信息
- (void)uploadExtraInformation:(NSString *)field andValue:(NSString *)value andKeyStr:(NSString *)key
{
    NSDictionary * params = @{@"uid":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"field":field,
                              @"value":value};
    
    debugLog(@"%@ %@", kChangePersonalExtraInformationPath, params);
    [HttpService postWithUrlString:kChangePersonalExtraInformationPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self.defaults setObject:value forKey:key];
            [self.defaults synchronize];
        }
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//上传用户信息 有状态的借口
- (void)updateDataInformationWithField:(NSString *)field andValue:(NSString *)value andStateField:(NSString *)stateField andStateValue:(NSInteger)stateValue
{
    NSDictionary * params = @{@"uid":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"field":field,
                              @"value":value,
                              @"state_field":stateField,
                              @"state_value":[NSString stringWithFormat:@"%ld", stateValue]};
    
    debugLog(@"%@ %@", kChangePersonalInformationStatePath, params);
    [HttpService postWithUrlString:kChangePersonalInformationStatePath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [[UserService sharedService].user setValue:value forKey:field];
            //状态更新
            if ([field compare:@"phone_num"] == NSOrderedSame) {
                [UserService sharedService].user.phone_state = stateValue;
            }else if ([field compare:@"e_mail"] == NSOrderedSame){
                [UserService sharedService].user.email_state = stateValue;
            }else if ([field compare:@"address"] == NSOrderedSame){
                [UserService sharedService].user.address_state = stateValue;
            }
            //数据缓存
            [[UserService sharedService] saveAndUpdate];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (CustomLabel *)setCommonCellWith:(NSString *)title andFrame:(CGRect)frame tag:(NSInteger)tag
{
    CustomButton * backView    = [[CustomButton alloc] initWithFrame:frame];
    backView.tag               = tag;
    backView.backgroundColor   = [UIColor whiteColor];
    
    CustomLabel * titleLabel   = [[CustomLabel alloc] initWithFontSize:15];
    titleLabel.frame           = CGRectMake(15, 10, 70, 30);
    titleLabel.textColor       = [UIColor colorWithHexString:ColorCharGary];
    titleLabel.text            = title;

    CustomLabel * contentLabel = [[CustomLabel alloc] initWithFontSize:15];
    contentLabel.frame         = CGRectMake(120, 10, self.viewWidth-135, 30);
    contentLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    contentLabel.textAlignment = NSTextAlignmentRight;
    
    UIView * lineView          = [[UIView alloc] initWithFrame:CGRectMake(0, backView.height-1, backView.width, 1)];
    lineView.backgroundColor   = [UIColor colorWithHexString:ColorLightGary];

    [backView addSubview:lineView];
    [backView addSubview:titleLabel];
    [backView addSubview:contentLabel];
    [self.backScrollView addSubview:backView];
    
    [backView addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    return contentLabel;
}

- (CustomLabel *)setCommonTitleCellFrame:(CGRect)frame tag:(NSInteger)tag
{
    CustomButton * backView    = [[CustomButton alloc] initWithFrame:frame];
    backView.tag               = tag;
    backView.backgroundColor   = [UIColor whiteColor];
    
    CustomLabel * contentLabel = [[CustomLabel alloc] initWithFontSize:15];
    contentLabel.frame         = CGRectMake(15, 10, 300, 30);
    contentLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    
    UIView * lineView          = [[UIView alloc] initWithFrame:CGRectMake(0, backView.height-1, backView.width, 1)];
    lineView.backgroundColor   = [UIColor colorWithHexString:ColorLightGary];
    
    [backView addSubview:lineView];
    [backView addSubview:contentLabel];
    [self.backScrollView addSubview:backView];
    
    [backView addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    return contentLabel;
}

#pragma mark- private method
//头像
- (void)headImageClick
{
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:KHClubString(@"Personal_PersonalSetting_Icon") delegate:self cancelButtonTitle:StringCommonCancel destructiveButtonTitle:nil otherButtonTitles:KHClubString(@"Common_Camera"), KHClubString(@"Common_Gallery"), nil];
    [sheet showInView:self.view];

}
//性别
- (void)sexClick
{
    
    UIAlertView * sexAlertView = [[UIAlertView alloc] initWithTitle:KHClubString(@"Personal_PersonalSetting_Sex") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:KHClubString(@"Personal_PersonalSetting_Man"),KHClubString(@"Personal_PersonalSetting_Woman"),StringCommonCancel, nil];
    [sexAlertView show];
}
//其他
- (void)infoChangeWith:(ChangePersonalType)type
{
    //除了 电话 地址 邮箱是有可见状态的外 其他的没有
    InformationChangeViewController * icvc = [[InformationChangeViewController alloc] init];
    icvc.changeType = type;
    //block 上传信息
    [icvc setChangeBlock:^(NSString *content, NSInteger state) {
        switch (type) {
            case ChangePersonalName:
                self.nameLabel.text = [ToolsManager emptyReturnNone:content];
                [self updateDataInformationWithField:@"name" andValue:content];
                break;
            case ChangePersonalSign:
                self.signLabel.text = [ToolsManager emptyReturnNone:content];
                [self updateDataInformationWithField:@"signature" andValue:content];
                break;
            case ChangePersonalJob:
                self.jobLabel.text = [ToolsManager emptyReturnNone:content];
                [self updateDataInformationWithField:@"job" andValue:content];
                break;
            case ChangePersonalPhone:
                self.phoneLabel.text = [ToolsManager emptyReturnNone:content];
                [self updateDataInformationWithField:@"phone_num" andValue:content andStateField:@"phone_state" andStateValue:state];
                break;
            case ChangePersonalAddress:
                self.addressLabel.text = [ToolsManager emptyReturnNone:content];
                [self updateDataInformationWithField:@"address" andValue:content andStateField:@"address_state" andStateValue:state];
                break;
            case ChangePersonalCompany:
                self.companyLabel.text = [ToolsManager emptyReturnNone:content];
                [self updateDataInformationWithField:@"company_name" andValue:content];
                break;
            case ChangePersonalEmail:
                self.emailLabel.text = [ToolsManager emptyReturnNone:content];
                [self updateDataInformationWithField:@"e_mail" andValue:content andStateField:@"email_state" andStateValue:state];
                break;
//            case ChangePersonalTitle1:
//                self.titleLabel1.text = [ToolsManager emptyReturnNone:content];
//                [self uploadExtraInformation:Title_1_Key andValue:content andKeyStr:Title_1_Key];
//                break;
//            case ChangePersonalTitle2:
//                self.titleLabel2.text = [ToolsManager emptyReturnNone:content];
//                [self uploadExtraInformation:Title_2_Key andValue:content andKeyStr:Title_2_Key];
//                break;
//            case ChangePersonalTitle3:
//                self.titleLabel3.text = [ToolsManager emptyReturnNone:content];
//                [self uploadExtraInformation:Title_3_Key andValue:content andKeyStr:Title_3_Key];
//                break;
//                
            default:
                break;
        }
    }];
    
//    //传内容
//    if (type == ChangePersonalTitle1) {
//        icvc.content = [self.defaults objectForKey:Title_1_Key];
//    }else if (type == ChangePersonalTitle2) {
//        icvc.content = [self.defaults objectForKey:Title_2_Key];
//    }else if (type == ChangePersonalTitle3) {
//        icvc.content = [self.defaults objectForKey:Title_3_Key];
//    }
    [self pushVC:icvc];
}



- (void)setData
{
    UserModel * user       = [UserService sharedService].user;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    self.nameLabel.text    = [ToolsManager emptyReturnNone:user.name];
    self.companyLabel.text = [ToolsManager emptyReturnNone:user.company_name];
    self.jobLabel.text     = [ToolsManager emptyReturnNone:user.job];
    self.phoneLabel.text   = [ToolsManager emptyReturnNone:user.phone_num];
    self.emailLabel.text   = [ToolsManager emptyReturnNone:user.e_mail];
    self.addressLabel.text = [ToolsManager emptyReturnNone:user.address];
    self.signLabel.text    = [ToolsManager emptyReturnNone:user.signature];

    if (user.sex == SexMale) {
        self.sexLabel.text = KHClubString(@"Personal_PersonalSetting_Man");
    }else{
        self.sexLabel.text = KHClubString(@"Personal_PersonalSetting_Woman");
    }
}

//- (void)getExtraInfo
//{
//    NSString * path = [kGetPersonalExtraInformationPath stringByAppendingFormat:@"?uid=%ld",[UserService sharedService].user.uid];
//    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
//        int status = [responseData[HttpStatus] intValue];
//        if (status == HttpStatusCodeSuccess) {
//            NSDictionary * resultDic = responseData[HttpResult];
//            self.titleLabel1.text    = [ToolsManager emptyReturnNone:resultDic[Title_1_Key]];
//            self.titleLabel2.text    = [ToolsManager emptyReturnNone:resultDic[Title_2_Key]];
//            self.titleLabel3.text    = [ToolsManager emptyReturnNone:resultDic[Title_3_Key]];
//
//            [self.defaults setObject:resultDic[Title_1_Key] forKey:Title_1_Key];
//            [self.defaults setObject:resultDic[Title_2_Key] forKey:Title_2_Key];
//            [self.defaults setObject:resultDic[Title_3_Key] forKey:Title_3_Key];
//            [self.defaults synchronize];
//        }
//        
//    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
