//
//  OtherPersonalViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/5.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "OtherPersonalViewController.h"
#import "CardChooseUserViewController.h"
#import "UIImageView+WebCache.h"
#import "PersonalInfoView.h"
#import "ImageModel.h"
#import "MyNewsListViewController.h"
#import "IMUtils.h"
#import "ChatViewController.h"
#import "ShareAlertPopView.h"
#import "ReportOffenceViewController.h"
#import "ShareUtils.h"
#import <objc/runtime.h>
@interface OtherPersonalViewController ()

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
//签名背景
@property (nonatomic, strong) UIView            * signBackView;
//签名
@property (nonatomic, strong) CustomLabel       * signLabel;
//用户模型
@property (nonatomic, strong) UserModel         * otherUser;
//是不是好友
@property (nonatomic, assign) BOOL              isFriend;
//添加或者发送消息 按钮
@property (nonatomic, strong) CustomButton      * sendOrAddBtn;
//右上角点击分享按钮
@property (nonatomic, strong) ShareAlertPopView * shareAlertPopView;
//图像背景
@property (nonatomic, strong) CustomButton      * imageBackView;
//备注
@property (nonatomic, copy  ) NSString          * remark;
//举报按钮
@property (nonatomic, strong) CustomButton      * reportBtn;

@end

@implementation OtherPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isFriend = [self didBuddyExist:[ToolsManager getCommonTargetId:self.uid]];
    if (self.newFriend) {
        //新好友
        self.isFriend = YES;
    }
    //初始化
    [self initWidget];
    //编辑UI
    [self configUI];
    
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)initWidget
{
    //背景滚动视图
    self.backScrollView    = [[UIScrollView alloc] init];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:@"" andBlock:^{
        if (!sself.otherUser) {
            return;
        }
        [sself.shareAlertPopView show];
    }];
    
    self.shareAlertPopView = [[ShareAlertPopView alloc] initWithIsFriend:self.isFriend];
    [self.shareAlertPopView setShareBlock:^(ShareAlertType type) {
        switch (type) {
            case ShareAlertFriend:
            {
                [sself sendToFriend];            
            }
            break;
            case ShareAlertWechat:
            {
                [ShareUtils shareWechatWithUser:sself.otherUser];
            }
            break;
            case ShareAlertWechatMoment:
            {
                [ShareUtils shareWechatMomentsWithUser:sself.otherUser];
            }
            break;
            case ShareAlertSina:
            {
                [ShareUtils shareSinaWithUser:sself.otherUser];
            }
            break;
            case ShareAlertQQ:
            {
                [ShareUtils shareQQWithUser:sself.otherUser];
            }
            break;
            case ShareAlertQzone:
            {
                [ShareUtils shareQzoneWithUser:sself.otherUser];
            }
            break;
            case ShareAlertRemark:
            {
                UIAlertView * alert     = [[UIAlertView alloc] initWithTitle:KHClubString(@"Personal_OtherPersonal_Remark") message:nil delegate:sself cancelButtonTitle:StringCommonCancel otherButtonTitles:StringCommonConfirm, nil];
                alert.alertViewStyle    = UIAlertViewStylePlainTextInput;
                UITextField * textField = [alert textFieldAtIndex:0];
                textField.text          = sself.remark;
                [alert show];
            }
                break;
            case ShareAlertDelete:
            {
                [sself deleteFriend];
            }
                
            default:
                break;
        }
        
        [sself.shareAlertPopView cancelPop];
    }];

    self.infoView          = [[PersonalInfoView alloc] initWithFrame:CGRectMake(10, 10, self.viewWidth-20, 190) isSelf:NO];
    self.imageBackView     = [[CustomButton alloc] init];
    self.imageView1        = [[CustomImageView alloc] init];
    self.imageView2        = [[CustomImageView alloc] init];
    self.imageView3        = [[CustomImageView alloc] init];
    
    //签名部分
    self.signBackView      = [[UIView alloc] init];
    self.signLabel         = [[CustomLabel alloc] init];
    //添加发送按钮
    self.sendOrAddBtn      = [[CustomButton alloc] init];
    //举报按钮
    self.reportBtn         = [[CustomButton alloc] init];
    
    [self.view addSubview:self.backScrollView];
    [self.backScrollView addSubview:self.infoView];
    [self.backScrollView addSubview:self.imageBackView];
    [self.backScrollView addSubview:self.signBackView];
    [self.signBackView addSubview:self.signLabel];
    [self.backScrollView addSubview:self.sendOrAddBtn];
    [self.navBar addSubview:self.reportBtn];
    
    [self.sendOrAddBtn addTarget:self action:@selector(sendOrAddClick:) forControlEvents:UIControlEventTouchUpInside];
    //设置页面UI刷新
    [self.infoView setRefreshBlock:^{
        sself.imageBackView.y = self.infoView.bottom+10;
        sself.signBackView.y  = self.imageBackView.bottom+1;
    }];
    
    [self.reportBtn addTarget:self action:@selector(reportClick:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)configUI
{
    [self.navBar setNavTitle:KHClubString(@"Personal_PersonalSetting_Title")];

    self.navBar.rightBtn.imageEdgeInsets       = UIEdgeInsetsMake(3, 5, 0, 0);
    self.navBar.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"personal_more"] forState:UIControlStateNormal];
    self.navBar.rightBtn.frame                 = CGRectMake([DeviceManager getDeviceWidth]-45, 20, 40, 44);

    self.reportBtn.frame                       = CGRectMake(self.navBar.rightBtn.x - 32, self.navBar.rightBtn.y+9, 30, 30);
    self.reportBtn.imageEdgeInsets             = UIEdgeInsetsMake(0, 5, 0, 0);
    self.reportBtn.imageView.contentMode       = UIViewContentModeScaleAspectFit;
    [self.reportBtn setImage:[UIImage imageNamed:@"report"] forState:UIControlStateNormal];
    
    //背景滚动视图
    self.backScrollView.frame                        = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;
    //顶部栏设置部分
    self.imageBackView.frame           = CGRectMake(0, self.infoView.bottom+10, self.viewWidth, 60);
    self.imageBackView.backgroundColor = [UIColor whiteColor];

    CustomLabel * imageLabel      = [[CustomLabel alloc] initWithFontSize:17];
    imageLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    imageLabel.frame              = CGRectMake(15, 0, 80, 60);
    imageLabel.text               = KHClubString(@"Personal_Personal_Moments");
    [self.imageBackView addSubview:imageLabel];
    [self.imageBackView addTarget:self action:@selector(myImageClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageView1.frame         = CGRectMake(imageLabel.right+5, 5, 50, 50);
    self.imageView2.frame         = CGRectMake(self.imageView1.right+5, 5, 50, 50);
    self.imageView3.frame         = CGRectMake(self.imageView2.right+5, 5, 50, 50);
    [self.imageBackView addSubview:self.imageView1];
    [self.imageBackView addSubview:self.imageView2];
    [self.imageBackView addSubview:self.imageView3];
    
    self.signBackView.frame           = CGRectMake(0, self.imageBackView.bottom+1, self.viewWidth, 60);
    self.signBackView.backgroundColor = [UIColor colorWithHexString:ColorWhite];
    
    CustomLabel * signTitleLabel      = [[CustomLabel alloc] initWithFontSize:17];
    signTitleLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    signTitleLabel.frame              = CGRectMake(15, 0, 100, 40);
    signTitleLabel.text               = KHClubString(@"Personal_Personal_Sign");
    [self.signBackView addSubview:signTitleLabel];
    
    self.signLabel.frame              = CGRectMake(15, signTitleLabel.bottom, self.viewWidth-30, 0);
    self.signLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    self.signLabel.font               = [UIFont systemFontOfSize:15];
    self.signLabel.numberOfLines      = 0;
    self.signLabel.lineBreakMode      = NSLineBreakByCharWrapping;

    self.sendOrAddBtn.frame           = CGRectMake(20, self.signBackView.bottom+20, self.viewWidth-40, 45);
    self.sendOrAddBtn.backgroundColor = [UIColor colorWithHexString:ColorGold];
    
    if (self.uid == [UserService sharedService].user.uid) {
        self.sendOrAddBtn.hidden = YES;
    }
    //是好友
    if (self.isFriend) {
        [self.sendOrAddBtn setTitle:KHClubString(@"Personal_OtherPersonal_Send") forState:UIControlStateNormal];
    }else {
        [self.sendOrAddBtn setTitle:KHClubString(@"Personal_OtherPersonal_AddFriend") forState:UIControlStateNormal];
    }
}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString * newRemark = [[alertView textFieldAtIndex:0].text trim];
        if (![self.remark isEqualToString:newRemark]) {
            [self setRemarkWith:newRemark];
        }
    }
}

#pragma mark- method response
- (void)sendToFriend
{
    CardChooseUserViewController * ccuvc = [[CardChooseUserViewController alloc] init];
    ccuvc.cardMessage                    = [[IMUtils shareInstance] generateCardMesssageWithUserModel:self.otherUser];
    [self presentViewController:ccuvc animated:YES completion:nil];
}

- (void)myImageClick:(id)sender
{
    MyNewsListViewController * mnlvc = [[MyNewsListViewController alloc] init];
    mnlvc.isOther                    = YES;
    mnlvc.uid                        = self.uid;
    [self pushVC:mnlvc];
}

- (void)sendOrAddClick:(id)sender
{
    if (self.isFriend) {
        ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:[ToolsManager getCommonTargetId:self.uid] isGroup:NO];
        [self pushVC:chatVC];
    }else{
        [self addContact];
    }
    
}

- (void)reportClick:(id)sender
{
    if (self.otherUser) {
        ReportOffenceViewController * rovc = [[ReportOffenceViewController alloc] init];
        rovc.reportUid                     = self.otherUser.uid;
        [self pushVC:rovc];
    }
}

#pragma mark- private method
//获取用户信息
- (void)getData
{
    //kGetNewsImagesPath
    NSString * path = [kPersnalInformationPath stringByAppendingFormat:@"?uid=%ld&current_id=%ld", self.uid, [UserService sharedService].user.uid];
    debugLog(@"%@", path);
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self handleDataWithDic:responseData];
        }else{
            [self showWarn:responseData[HttpMessage]];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

//处理数据
- (void)handleDataWithDic:(NSDictionary *)responseData
{
    //用户信息
    self.otherUser      = [[UserModel alloc] init];
    [self.otherUser setModelWithDic:responseData[HttpResult]];
    
    [self setNavBarTitle:self.otherUser.name];
    
    //签名
    NSString * signStr       = [ToolsManager emptyReturnNone:self.otherUser.signature];
    CGSize size              = [ToolsManager getSizeWithContent:signStr andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
    self.signLabel.text      = signStr;
    self.signBackView.height = size.height+50;
    self.signLabel.height    = size.height;
    
    if (self.signBackView.bottom < self.backScrollView.height) {
        self.backScrollView.contentSize = CGSizeMake(0, self.backScrollView.height+1);
    }else{
        self.backScrollView.contentSize = CGSizeMake(0, self.signBackView.height+10);
    }
    //布局
    self.sendOrAddBtn.y = self.signBackView.bottom + 20;
    //图片数组
    NSArray * imageList = responseData[HttpResult][@"image_list"];
    
    NSMutableArray * imageModelList = [[NSMutableArray alloc] init];
    //遍历设置图片
    for (int i=0; i<imageList.count; i++) {
        NSDictionary * dic = imageList[i];
        ImageModel * image = [[ImageModel alloc] init];
        image.sub_url      = dic[@"sub_url"];
        image.url          = dic[@"url"];
        [imageModelList addObject:image];
    }
    //图片
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
    
    //是否收藏
    self.infoView.isCollect = [responseData[HttpResult][@"isCollected"] boolValue];
    //是否好友
    self.infoView.isFriend  = self.isFriend;
    //是好友的话备注
    self.infoView.remark    = responseData[HttpResult][@"remark"];
    self.remark             = responseData[HttpResult][@"remark"];
    self.infoView.parentVC  = self;
    //设置数据
    [self.infoView setDataWithModel:self.otherUser];
}

- (void)deleteFriend
{
    [self showHudInView:self.view hint:@""];
    
    NSString * username = [ToolsManager getCommonTargetId:self.otherUser.uid];
    //删除好友
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"target_id":[NSString stringWithFormat:@"%ld", self.otherUser.uid]};
    [HttpService postWithUrlString:kDeleteFriendPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        [self hideHud];
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            EMError *error = nil;
            [[EaseMob sharedInstance].chatManager removeBuddy:username removeFromRemote:YES error:&error];
            if (!error) {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:username deleteMessages:YES append2Chat:YES];
                [[IMUtils shareInstance] cacheBuddysToDiskWithRemoveUsername:username];
                
                //三个地方需要修改
                self.isFriend                   = NO;
                self.infoView.isFriend          = NO;
                self.shareAlertPopView.isFriend = NO;
                [self.infoView setDataWithModel:self.otherUser];
                
                [self.sendOrAddBtn setTitle:KHClubString(@"Personal_OtherPersonal_AddFriend") forState:UIControlStateNormal];                
            }
            else{
                [self showHint:[NSString stringWithFormat:NSLocalizedString(@"deleteFailed", @"Delete failed")]];
            }
            
        }else{
            [self showHint:StringCommonNetException];
        }
        
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHud];
        [self showHint:StringCommonNetException];
    }];

}

- (BOOL)didBuddyExist:(NSString *)buddyName
{
    
    NSArray *buddyList = [[[EaseMob sharedInstance] chatManager] buddyList];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName] &&
            buddy.followState != eEMBuddyFollowState_NotFollowed) {
            return YES;
        }
    }

    buddyList = [[IMUtils shareInstance] getBuddys];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username isEqualToString:buddyName]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addContact
{

    NSString *buddyName = [ToolsManager getCommonTargetId:self.uid];
    if (buddyName && buddyName.length > 0) {
        [self showHudInView:self.view hint:NSLocalizedString(@"friend.sendApply", @"sending application...")];
        EMError *error;
        [[EaseMob sharedInstance].chatManager addBuddy:buddyName message:[NSString stringWithFormat:NSLocalizedString(@"friend.somebodyInvite", @"invite you as a friend")] error:&error];
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"friend.sendApplyFail", @"send application fails, please operate again")];
        }
        else{
            [self showHint:NSLocalizedString(@"friend.sendApplySuccess", @"send successfully")];
        }
    }
}

/**
 *  设置备注
 *
 *  @param remark 备注
 */
- (void)setRemarkWith:(NSString *)remark
{
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"target_id":[NSString stringWithFormat:@"%ld", self.uid],
                              @"friend_remark":remark};
    
    [self showLoading:StringCommonUploadData];
    
    [HttpService postWithUrlString:kAddRemarkPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        [self hideLoading];
        int status = [responseData[HttpStatus] intValue];
        //成功后
        if (status == HttpStatusCodeSuccess) {
            self.infoView.remark = remark;
            self.remark          = remark;
            //设置数据
            [self.infoView setDataWithModel:self.otherUser];
            //如果有备注设置本地缓存
            if (remark.length > 0) {
                [[IMUtils shareInstance] setUserNickWithStr:remark andUsername:[NSString stringWithFormat:@"%@%ld", KH, self.uid]];
            }else{
                [[IMUtils shareInstance] setUserNickWithStr:self.otherUser.name andUsername:[NSString stringWithFormat:@"%@%ld", KH, self.uid]];
            }
        }else{
            [self showHint:StringCommonUploadDataFail];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideLoading];
        [self showHint:StringCommonNetException];
    }];
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
