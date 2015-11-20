/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "CreateGroupViewController.h"
#import "IMUtils.h"
#import "ContactSelectionViewController.h"
#import "EMTextView.h"

@interface CreateGroupViewController ()<UITextFieldDelegate, UITextViewDelegate, EMChooseViewDelegate>

//封面
@property (nonatomic, strong) CustomImageView * topicImageView;
//封面上的提示label
@property (nonatomic, strong) CustomLabel * coverLabel;

@property (strong, nonatomic) UITextField *textField;

@end

@implementation CreateGroupViewController

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

    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];

    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:NSLocalizedString(@"group.create.addOccupant", @"add members") andBlock:^{
        [sself addContacts:nil];
    }];
    
    [self initWidget];
    [self configUI];
    [self.view addSubview:self.textField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)initWidget
{
    self.topicImageView     = [[CustomImageView alloc] init];
    self.coverLabel         = [[CustomLabel alloc] init];
    
    [self.topicImageView addSubview:self.coverLabel];
    [self.view addSubview:self.topicImageView];
    
    //选择图片手势
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topicImageTap:)];
    [self.topicImageView addGestureRecognizer:tap];
  
}

- (void)configUI
{
 
    self.navBar.rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [self setNavBarTitle:NSLocalizedString(@"title.createGroup", @"Create a group")];
    //图片
    self.topicImageView.frame                  = CGRectMake(kCenterOriginX(100), kNavBarAndStatusHeight+40, 100, 100);
    self.topicImageView.backgroundColor        = [UIColor colorWithHexString:ColorGary];
    self.topicImageView.userInteractionEnabled = YES;
    self.topicImageView.layer.masksToBounds    = YES;
    self.topicImageView.contentMode            = UIViewContentModeScaleAspectFill;
    
    self.coverLabel.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    self.coverLabel.frame           = CGRectMake(0, 70, 100, 30);
    self.coverLabel.font            = [UIFont systemFontOfSize:13];
    self.coverLabel.textAlignment   = NSTextAlignmentCenter;
    self.coverLabel.text            = KHClubString(@"Message_Create_Cover");
    self.coverLabel.textColor       = [UIColor colorWithHexString:ColorWhite];
    
}

#pragma mark - getter

- (UITextField *)textField
{
    if (_textField == nil) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(kCenterOriginX(300), 15 + self.topicImageView.bottom, 300, 40)];
        _textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _textField.layer.borderWidth = 0.5;
        _textField.layer.cornerRadius = 3;
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.font = [UIFont systemFontOfSize:15.0];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.placeholder = NSLocalizedString(@"group.create.inputName", @"please enter the group name");
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
    }
    
    return _textField;
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
    self.coverLabel.hidden    = YES;
    self.topicImageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EMChooseViewDelegate

- (void)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources
{
    
    if (self.textField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"group.create.inputName", @"please enter the group name") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self showHudInView:self.view hint:NSLocalizedString(@"group.create.ongoing", @"create a group...")];
    NSMutableString * mutableStr = [NSMutableString stringWithString:@""];
    for (EMBuddy * buddy in selectedSources) {
        [mutableStr appendString:[NSString stringWithFormat:@"%@,", buddy.username]];
    }
    if (mutableStr.length > 0) {
       mutableStr = [NSMutableString stringWithString:[mutableStr substringToIndex:mutableStr.length-1]];
    }
    
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"group_name":[self.textField.text trim],
                              @"members":mutableStr};
    debugLog(@"%@", params);

    NSString * fileName = [ToolsManager getUploadImageName];
    NSArray * files = @[@{FileDataKey:UIImageJPEGRepresentation(self.topicImageView.image, 0.9),FileNameKey:fileName}];

    [HttpService postFileWithUrlString:kCreateGroupPath params:params files:files andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        [self hideHud];
        int status = [responseData[@"status"] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self showHint:NSLocalizedString(@"group.create.success", @"create group success")];
            NSDictionary * topicDic = responseData[HttpResult];
            //缓存二维码和图片
            [[IMUtils shareInstance] saveGroupImage:topicDic[@"group_cover"] groupName:topicDic[@"group_id"]];
            [[IMUtils shareInstance] saveQrCode:topicDic[@"group_qr_code"] groupName:topicDic[@"group_id"]];
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [self showHint:NSLocalizedString(@"group.create.fail", @"Failed to create a group, please operate again")];
        }
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHud];
        [self showHint:StringCommonNetException];
    }];
    
}

#pragma mark - action

- (void)topicImageTap:(UITapGestureRecognizer *)sender
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:StringCommonCancel destructiveButtonTitle:nil otherButtonTitles:KHClubString(@"Common_Camera"),KHClubString(@"Common_Gallery"), nil];
    [sheet showInView:self.view];
}

- (void)addContacts:(id)sender
{
    if (self.textField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"group.create.inputName", @"please enter the group name") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    
    ContactSelectionViewController *selectionController = [[ContactSelectionViewController alloc] init];
    selectionController.delegate = self;
    [self.navigationController pushViewController:selectionController animated:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textField resignFirstResponder];
}

@end
