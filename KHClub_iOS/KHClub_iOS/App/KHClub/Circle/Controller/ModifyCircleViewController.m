//
//  ModifyCircleViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/11.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "ModifyCircleViewController.h"
#import "UIImageView+WebCache.h"

@interface ModifyCircleViewController ()<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIScrollView    * backScrollView;
//封面
@property (nonatomic, strong) CustomImageView * circleImageView;
//封面上的提示label
@property (nonatomic, strong) CustomLabel     * coverLabel;
//圈子昵称
@property (nonatomic, strong) UITextField     * circleNameTextField;
//圈子介绍
@property (nonatomic, strong) UITextField     * circleIntroTextField;
//圈子地址
@property (nonatomic, strong) UITextField     * circleAddressTextField;
//圈子电话
@property (nonatomic, strong) UITextField     * circlePhoneTextField;
//圈子公众号
@property (nonatomic, strong) UITextField     * wxTextField;
//二维码图片
@property (nonatomic, strong) CustomImageView * wxQRcodeImageView;
//圈子网址
@property (nonatomic, strong) UITextField     * circleWebTextField;
//当前图片类型 1是封面 2是二维码
@property (nonatomic, assign) NSInteger       currentImageType;
//封面修改
@property (nonatomic, assign) BOOL            coverChanged;
//二维码修改
@property (nonatomic, assign) BOOL            qrcodeChanged;

@end

@implementation ModifyCircleViewController
{
    ModifyCircleBlock _block;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:StringCommonSubmit andBlock:^{
        [sself createCircleVerify];
    }];
    
    [self initWidget];
    [self configUI];
    [self setData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)initWidget
{
    self.backScrollView     = [[UIScrollView alloc] init];
    self.circleImageView    = [[CustomImageView alloc] init];
    self.coverLabel         = [[CustomLabel alloc] init];
    self.wxQRcodeImageView  = [[CustomImageView alloc] init];
    
    [self.view addSubview:self.backScrollView];
    [self.circleImageView addSubview:self.coverLabel];
    [self.backScrollView addSubview:self.circleImageView];
    [self.backScrollView addSubview:self.wxQRcodeImageView];
    
    //选择图片手势
    UITapGestureRecognizer * tap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(circleImageTap:)];
    [self.circleImageView addGestureRecognizer:tap];
    
    //选择图片手势
    UITapGestureRecognizer * qrTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qrImageTap:)];
    [self.wxQRcodeImageView addGestureRecognizer:qrTap];
    
    //收键盘
    UITapGestureRecognizer * scrollTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTap:)];
    [self.backScrollView addGestureRecognizer:scrollTap];
}

- (void)configUI
{
    
    self.navBar.rightBtn.titleLabel.font             = [UIFont systemFontOfSize:14];
    [self setNavBarTitle:KHClubString(@"Circle_CreateCircle_Title")];
    //背景
    self.backScrollView.frame                        = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;
    self.backScrollView.backgroundColor              = [UIColor whiteColor];
    //图片
    self.circleImageView.frame                        = CGRectMake(kCenterOriginX(76), 10, 76, 76);
    self.circleImageView.backgroundColor              = [UIColor colorWithHexString:ColorGary];
    self.circleImageView.userInteractionEnabled       = YES;
    self.circleImageView.layer.masksToBounds          = YES;
    self.circleImageView.contentMode                  = UIViewContentModeScaleAspectFill;
    
    self.coverLabel.backgroundColor                  = [UIColor colorWithWhite:0.4 alpha:0.5];
    self.coverLabel.frame                            = CGRectMake(0, 56, 76, 20);
    self.coverLabel.font                             = [UIFont systemFontOfSize:13];
    self.coverLabel.textAlignment                    = NSTextAlignmentCenter;
    self.coverLabel.text                             = KHClubString(@"Message_Create_Cover");
    self.coverLabel.textColor                        = [UIColor colorWithHexString:ColorWhite];
    
    //圈子昵称
    self.circleNameTextField                      = [self getCommonTextFieldWithPlaceHolder:KHClubString(@"Circle_Circle_NamePlaceholder") andTitle:KHClubString(@"Circle_Circle_NameTitle") andTilteFrame:CGRectMake(10, self.circleImageView.bottom+10, 32, 15)];
    //圈子介绍
    self.circleIntroTextField                     = [self getCommonTextFieldWithPlaceHolder:KHClubString(@"Circle_Circle_IntroPlaceholder") andTitle:KHClubString(@"Circle_Circle_IntroTitle") andTilteFrame:CGRectMake(10, self.circleImageView.bottom+10+40, 32, 15)];
    //圈子地址
    self.circleAddressTextField                   = [self getCommonTextFieldWithPlaceHolder:@"" andTitle:KHClubString(@"Circle_Circle_AddressTitle") andTilteFrame:CGRectMake(10, self.circleImageView.bottom+10+40*2, 32, 15)];
    //圈子电话
    self.circlePhoneTextField                     = [self getCommonTextFieldWithPlaceHolder:@"" andTitle:KHClubString(@"Circle_Circle_PhoneTitle") andTilteFrame:CGRectMake(10, self.circleImageView.bottom+10+40*3, 32, 15)];
    //圈子公众号
    self.wxTextField                              = [self getCommonTextFieldWithPlaceHolder:@"" andTitle:KHClubString(@"Circle_Circle_WechatTitle") andTilteFrame:CGRectMake(10, self.circleImageView.bottom+10+40*4, 65, 15)];
    
    CustomLabel * qrTitleLabel = [[CustomLabel alloc] initWithFontSize:13];
    qrTitleLabel.frame         = CGRectMake(10, self.circleImageView.bottom+10+40*5, 78, 15);
    qrTitleLabel.text          = KHClubString(@"Circle_Circle_WechatQrcodeTitle");
    [self.backScrollView addSubview:qrTitleLabel];
    
    self.wxQRcodeImageView.frame                  = CGRectMake(qrTitleLabel.right+20, self.wxTextField.bottom+15, 35, 35);
    self.wxQRcodeImageView.backgroundColor        = [UIColor colorWithHexString:ColorGary];
    self.wxQRcodeImageView.userInteractionEnabled = YES;
    self.wxQRcodeImageView.layer.masksToBounds    = YES;
    self.wxQRcodeImageView.contentMode            = UIViewContentModeScaleAspectFill;
    //圈子网址
    self.circleWebTextField                       = [self getCommonTextFieldWithPlaceHolder:@"" andTitle:KHClubString(@"Circle_Circle_WebTitle") andTilteFrame:CGRectMake(10, self.circleImageView.bottom+10+40*6, 52, 15)];
    
    if (self.circleWebTextField.bottom > self.backScrollView.height) {
        self.backScrollView.contentSize = CGSizeMake(0, self.circleWebTextField.bottom+30);
    }else{
        self.backScrollView.contentSize = CGSizeMake(0, self.backScrollView.height+1);
    }
    
}

- (void)setData
{
    //封面
    [self.circleImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:self.circleModel.circle_cover_sub_image]]];
    //公众号二维码
    [self.wxQRcodeImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:self.circleModel.wx_qrcode]]];
    //名字
    self.circleNameTextField.text    = self.circleModel.circle_name;
    //详情
    self.circleIntroTextField.text   = self.circleModel.circle_detail;
    //地址
    self.circleAddressTextField.text = self.circleModel.address;
    //电话
    self.circlePhoneTextField.text   = self.circleModel.phone_num;
    //公众号
    self.wxTextField.text            = self.circleModel.wx_num;
    //网址
    self.circleWebTextField.text     = self.circleModel.circle_web;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.currentImageType = actionSheet.tag;
    //选照片
    if (buttonIndex != 2) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
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
    UIImage * image           = [ImageHelper getBigImage:info[UIImagePickerControllerOriginalImage]];
    if (self.currentImageType == 1) {
        self.coverLabel.hidden     = YES;
        self.circleImageView.image = image;
        //封面修改
        self.coverChanged          = YES;
    }else{
        self.wxQRcodeImageView.image = image;
        //二维码修改
        self.qrcodeChanged           = YES;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - method response

- (void)circleImageTap:(UITapGestureRecognizer *)sender
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:StringCommonCancel destructiveButtonTitle:nil otherButtonTitles:KHClubString(@"Common_Camera"),KHClubString(@"Common_Gallery"), nil];
    sheet.tag             = 1;
    [sheet showInView:self.view];
}

- (void)qrImageTap:(UITapGestureRecognizer *)sender
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:StringCommonCancel destructiveButtonTitle:nil otherButtonTitles:KHClubString(@"Common_Camera"),KHClubString(@"Common_Gallery"), nil];
    sheet.tag             = 2;
    [sheet showInView:self.view];
}

- (void)scrollTap:(UITapGestureRecognizer *)sender
{
    [self.circleNameTextField resignFirstResponder];
    [self.circleIntroTextField resignFirstResponder];
    [self.circleAddressTextField resignFirstResponder];
    [self.circlePhoneTextField resignFirstResponder];
    [self.wxTextField resignFirstResponder];
    [self.circleWebTextField resignFirstResponder];
}

#pragma mark- private method
- (UITextField *)getCommonTextFieldWithPlaceHolder:(NSString *)placeHolder andTitle:(NSString *)string andTilteFrame:(CGRect)frame
{
    
    CustomLabel * titleLabel = [[CustomLabel alloc] initWithFontSize:13];
    titleLabel.frame         = frame;
    titleLabel.text          = string;
    
    UITextField * textField            = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.right+5, frame.origin.y-5, self.viewWidth-titleLabel.right-15, 22)];
    textField.leftView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.leftViewMode             = UITextFieldViewModeAlways;
    textField.clearButtonMode          = UITextFieldViewModeWhileEditing;
    textField.font                     = [UIFont systemFontOfSize:12.0];
    textField.placeholder              = placeHolder;
    textField.delegate                 = self;
    [textField addBottomBorderWithColor:[UIColor colorWithHexString:ColorLightGary] andWidth:1];
    
    [self.backScrollView addSubview:titleLabel];
    [self.backScrollView addSubview:textField];
    
    return textField;
}

/**
 *  创建圈子验证
 */
- (void)createCircleVerify
{
    
    //标题不能为空
    if (self.circleNameTextField.text.length < 1) {
        [self showHint:KHClubString(@"Circle_CreateCircle_NameNotNull")];
        return;
    }
    //不能超过7位
    if (self.circleNameTextField.text.length > 7) {
        [self showHint:KHClubString(@"Circle_CreateCircle_NameTooLong")];
        return;
    }
    
    if (self.circleIntroTextField.text.length > 200) {
        [self showHint:KHClubString(@"Circle_CreateCircle_DetailTooLong")];
        return;
    }
    if (self.circleAddressTextField.text.length > 50) {
        [self showHint:KHClubString(@"Circle_CreateCircle_AddressTooLong")];
        return;
    }
    if (self.circlePhoneTextField.text.length > 50) {
        [self showHint:KHClubString(@"Circle_CreateCircle_PhoneTooLong")];
        return;
    }
    if (self.wxTextField.text.length > 50) {
        [self showHint:KHClubString(@"Circle_CreateCircle_WxTooLong")];
        return;
    }
    if (self.circleWebTextField.text.length > 50) {
        [self showHint:KHClubString(@"Circle_CreateCircle_WebTooLong")];
        return;
    }
    
    [self modifyCircle];
    
}

/**
 *  创建圈子提交
 */
- (void)modifyCircle
{
    
    NSDictionary * params = @{@"circle_id":[NSString stringWithFormat:@"%ld", self.circleModel.cid],
                              @"circle_name":self.circleNameTextField.text,
                              @"circle_detail":self.circleIntroTextField.text,
                              @"address":self.circleAddressTextField.text,
                              @"wx_num":self.wxTextField.text,
                              @"phone_num":self.circlePhoneTextField.text,
                              @"circle_web":self.circleWebTextField.text};
    
    //封面和二维码处理
    NSString * fileName    = [ToolsManager getUploadImageName];
    NSMutableArray * files = [[NSMutableArray alloc] init];
    
    if (self.coverChanged) {
        [files addObject:@{FileDataKey:UIImageJPEGRepresentation(self.circleImageView.image,0.9),FileNameKey:fileName}];
    }
    
    if (self.qrcodeChanged) {
        [files addObject:@{FileDataKey:UIImageJPEGRepresentation(self.wxQRcodeImageView.image,0.9),FileNameKey:[NSString stringWithFormat:@"qrcode%@", fileName]}];
    }
    
    debugLog(@"%@ %@", kModifyCirclePath, params);
    //修改圈子
    [self showHudInView:self.view hint:StringCommonUploadData];
    [HttpService postFileWithUrlString:kModifyCirclePath params:params files:files andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[@"status"] intValue];
        [self hideHud];
        if (status == HttpStatusCodeSuccess) {
            //圈子模型注入
            NSDictionary * cicleDic                 = responseData[HttpResult];
            self.circleModel.address                = cicleDic[@"address"];
            self.circleModel.circle_cover_image     = cicleDic[@"circle_cover_image"];
            self.circleModel.circle_cover_sub_image = cicleDic[@"circle_cover_sub_image"];
            self.circleModel.circle_detail          = cicleDic[@"circle_detail"];
            self.circleModel.circle_name            = cicleDic[@"circle_name"];
            self.circleModel.circle_web             = cicleDic[@"circle_web"];
            self.circleModel.wx_num                 = cicleDic[@"wx_num"];
            self.circleModel.wx_qrcode              = cicleDic[@"wx_qrcode"];
            self.circleModel.manager_name           = cicleDic[@"name"];
            self.circleModel.phone_num              = cicleDic[@"phone_num"];
            self.circleModel.managerId              = [cicleDic[@"user_id"] integerValue];
            
            if (_block) {
                _block();
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [self showFail:StringCommonUploadDataFail];
        }
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showFail:StringCommonNetException];
    }];
}

- (void)setModifyBlock:(ModifyCircleBlock)block
{
    _block = [block copy];
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
