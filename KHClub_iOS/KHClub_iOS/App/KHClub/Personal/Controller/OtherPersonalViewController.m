//
//  OtherPersonalViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/5.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "OtherPersonalViewController.h"
#import "CardChooseUserViewController.h"
#import "AddRemarkViewController.h"
#import "UIImageView+WebCache.h"
#import "PersonalInfoView.h"
#import "ImageModel.h"
#import "MyNewsListViewController.h"
#import "IMUtils.h"
#import "ChatViewController.h"
#import "ShareAlertPopView.h"
#import "ReportOffenceViewController.h"
#import "ShareUtils.h"
#import "MyCircleListViewController.h"

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
//用户模型
@property (nonatomic, strong) UserModel         * otherUser;
//是不是好友
@property (nonatomic, assign) BOOL              isFriend;
//添加或者发送消息 按钮
@property (nonatomic, strong) CustomButton      * sendOrAddBtn;
//分享按钮
@property (nonatomic, strong) CustomButton      * shareBtn;
//右上角点击分享按钮
@property (nonatomic, strong) ShareAlertPopView * shareAlertPopView;
//图像背景
@property (nonatomic, strong) CustomButton      * imageBackView;
//圈子背景
@property (nonatomic, strong) CustomButton      * myCircleBackView;
//备注
@property (nonatomic, copy  ) NSString          * remark;
//弹出视图背景
@property (nonatomic, strong) UIView            * popBackView;
//屏幕遮罩
@property (nonatomic, strong) UIView            * screenCoverView;

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
    [self getCircles];
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
        if (sself.isFriend) {
            [sself showRightPopView];
        }else{
            [sself reportClick:nil];
        }
        
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

            }
                break;
            case ShareAlertDelete:
            {

            }
                
            default:
                break;
        }
        
        [sself.shareAlertPopView cancelPop];
    }];

    self.infoView          = [[PersonalInfoView alloc] initWithFrame:CGRectMake(10, 10, self.viewWidth-20, 190) isSelf:NO];
    self.imageBackView     = [[CustomButton alloc] init];
    //圈子背景
    self.myCircleBackView  = [[CustomButton alloc] init];
    self.imageView1        = [[CustomImageView alloc] init];
    self.imageView2        = [[CustomImageView alloc] init];
    self.imageView3        = [[CustomImageView alloc] init];
    self.circleImageView1  = [[CustomImageView alloc] init];
    self.circleImageView2  = [[CustomImageView alloc] init];
    self.circleImageView3  = [[CustomImageView alloc] init];
    //签名部分
    self.signBackView      = [[UIView alloc] init];
    self.signLabel         = [[CustomLabel alloc] init];
    //添加发送按钮
    self.sendOrAddBtn      = [[CustomButton alloc] init];
    self.shareBtn          = [[CustomButton alloc] init];
    //举报按钮
    self.screenCoverView   = [[UIView alloc] init];
    self.popBackView       = [[UIView alloc] init];
    
    [self.view addSubview:self.backScrollView];
    [self.backScrollView addSubview:self.infoView];
    [self.backScrollView addSubview:self.imageBackView];
    [self.backScrollView addSubview:self.myCircleBackView];    
    [self.backScrollView addSubview:self.signBackView];
    [self.signBackView addSubview:self.signLabel];
    [self.backScrollView addSubview:self.sendOrAddBtn];
    [self.backScrollView addSubview:self.shareBtn];
    [self.imageBackView addSubview:self.imageView1];
    [self.imageBackView addSubview:self.imageView2];
    [self.imageBackView addSubview:self.imageView3];
    [self.myCircleBackView addSubview:self.circleImageView1];
    [self.myCircleBackView addSubview:self.circleImageView2];
    [self.myCircleBackView addSubview:self.circleImageView3];
    [self.view addSubview:self.screenCoverView];
    [self.view addSubview:self.popBackView];
    
    //设置页面UI刷新
    [self.infoView setRefreshBlock:^{
        sself.imageBackView.y    = self.infoView.bottom+10;
        sself.myCircleBackView.y = self.imageBackView.bottom+1;
        sself.signBackView.y     = self.myCircleBackView.bottom+1;
    }];
    
    [self.sendOrAddBtn addTarget:self action:@selector(sendOrAddClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageBackView addTarget:self action:@selector(myImageClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.myCircleBackView addTarget:self action:@selector(myCircleClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    //遮罩点击消失
    UITapGestureRecognizer * dissmissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCover:)];
    [self.screenCoverView addGestureRecognizer:dissmissTap];
}

- (void)configUI
{
    [self.navBar setNavTitle:KHClubString(@"Personal_PersonalSetting_Title")];

    self.navBar.rightBtn.imageEdgeInsets       = UIEdgeInsetsMake(3, 5, 0, 0);
    self.navBar.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    self.navBar.rightBtn.frame                 = CGRectMake([DeviceManager getDeviceWidth]-45, 20, 40, 44);
    
    //背景滚动视图
    self.backScrollView.frame                        = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;
    //顶部栏设置部分
    self.imageBackView.frame           = CGRectMake(0, self.infoView.bottom+10, self.viewWidth, 60);
    self.imageBackView.backgroundColor = [UIColor whiteColor];
    //TA的状态
    CustomLabel * imageLabel      = [[CustomLabel alloc] initWithFontSize:17];
    imageLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    imageLabel.frame              = CGRectMake(15, 0, 80, 60);
    imageLabel.text               = KHClubString(@"Personal_Personal_HisNews");
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
    self.imageView1.layer.cornerRadius  = 25;
    self.imageView2.layer.cornerRadius  = 25;
    self.imageView3.layer.cornerRadius  = 25;
    
    //TA的圈子
    self.myCircleBackView.frame               = CGRectMake(0, self.imageBackView.bottom+1, self.viewWidth, 60);
    self.myCircleBackView.backgroundColor     = [UIColor whiteColor];
    CustomLabel * circleLabel                 = [[CustomLabel alloc] initWithFontSize:17];
    circleLabel.textColor                     = [UIColor colorWithHexString:ColorDeepBlack];
    circleLabel.frame                         = CGRectMake(15, 0, 80, 60);
    circleLabel.text                          = KHClubString(@"Personal_Personal_HisCircle");
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
    self.circleImageView1.layer.cornerRadius  = 25;
    self.circleImageView2.layer.cornerRadius  = 25;
    self.circleImageView3.layer.cornerRadius  = 25;
    
    self.signBackView.frame           = CGRectMake(0, self.myCircleBackView.bottom+1, self.viewWidth, 60);
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
    
    //发送消息
    self.sendOrAddBtn.frame              = CGRectMake(25, self.signBackView.bottom+20, (self.viewWidth-75)/2, 40);
    self.sendOrAddBtn.backgroundColor    = [UIColor colorWithHexString:ColorGold];
    //分享
    self.shareBtn.frame                  = CGRectMake(self.sendOrAddBtn.right+25, self.signBackView.bottom+20, (self.viewWidth-75)/2, 40);
    self.shareBtn.backgroundColor        = [UIColor colorWithHexString:ColorGold];
    self.sendOrAddBtn.titleLabel.font    = [UIFont systemFontOfSize:16];
    self.shareBtn.titleLabel.font        = [UIFont systemFontOfSize:16];
    self.sendOrAddBtn.layer.cornerRadius = 3;
    self.shareBtn.layer.cornerRadius     = 3;
    
    //右上角PopView
    self.popBackView.backgroundColor     = [UIColor colorWithHexString:@"4d4d4d"];
    self.popBackView.layer.masksToBounds = YES;
    self.screenCoverView.frame           = self.view.bounds;
    self.screenCoverView.hidden          = YES;
    
    if (self.uid == [UserService sharedService].user.uid) {
        self.sendOrAddBtn.hidden = YES;
        self.shareBtn.hidden     = YES;
    }
    
    [self.shareBtn setTitle:KHClubString(@"Personal_OtherPersonal_ShareCard") forState:UIControlStateNormal];
    //是好友
    if (self.isFriend) {
        [self.sendOrAddBtn setTitle:KHClubString(@"Personal_OtherPersonal_Send") forState:UIControlStateNormal];
    }else {
        [self.sendOrAddBtn setTitle:KHClubString(@"Personal_OtherPersonal_AddFriend") forState:UIControlStateNormal];
    }
    
    //扫描二维码
    CustomButton * remarkBtn       = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    //添加好友
    CustomButton * deleteFriendBtn = [[CustomButton alloc] initWithFrame:CGRectMake(0, 40, 100, 40)];
    //新建群聊
    CustomButton * clearBtn        = [[CustomButton alloc] initWithFrame:CGRectMake(0, 80, 100, 40)];
    //新建举报
    CustomButton * reportBtn       = [[CustomButton alloc] initWithFrame:CGRectMake(0, 120, 100, 40)];

    
    [self defaultTopRightBtnHandle:remarkBtn imageName:@"edit_remark" andTitle:KHClubString(@"Personal_OtherPersonal_Remark")];
    [self defaultTopRightBtnHandle:deleteFriendBtn imageName:@"delete_friend" andTitle:KHClubString(@"Personal_OtherPersonal_DeleteFriend")];
    [self defaultTopRightBtnHandle:clearBtn imageName:@"clear" andTitle:KHClubString(@"Personal_OtherPersonal_ClearMessage")];
    [self defaultTopRightBtnHandle:reportBtn imageName:@"report" andTitle:KHClubString(@"Personal_OtherPersonal_Report")];
    
    remarkBtn.tag       = 1;
    deleteFriendBtn.tag = 2;
    clearBtn.tag        = 3;
    reportBtn.tag       = 4;
}
//默认
- (void)defaultTopRightBtnHandle:(CustomButton *)btn imageName:(NSString *)imageName andTitle:(NSString *)title
{
    CustomImageView * leftImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(10, 12, 16, 16)];
    leftImageView.contentMode       = UIViewContentModeScaleAspectFit;
    leftImageView.image             = [UIImage imageNamed:imageName];
    [btn addSubview:leftImageView];
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentEdgeInsets          = UIEdgeInsetsMake(0, 35, 0, 0);
    btn.titleLabel.font            = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:ColorLightWhite] forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    [self.popBackView addSubview:btn];
    
    UIView * lineView        = [[UIView alloc] initWithFrame:CGRectMake(0, btn.height-1, btn.width, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:ColorWhite];
    [btn addSubview:lineView];
    
    [btn addTarget:self action:@selector(popViewClick:) forControlEvents:UIControlEventTouchUpInside];
}

//显示右边弹窗
- (void)showRightPopView
{
    self.screenCoverView.hidden = NO;
    self.popBackView.frame      = CGRectMake(self.viewWidth-35, kNavBarAndStatusHeight, 0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.popBackView.frame                   = CGRectMake(self.viewWidth-110, kNavBarAndStatusHeight, 100, 160);
        //        self.navBar.rightBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
    }];
}

//遮罩点击消失
- (void)dismissCover:(UITapGestureRecognizer *)ges
{
    self.screenCoverView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.popBackView.frame                   = CGRectMake(self.viewWidth-110, kNavBarAndStatusHeight, 100, 0);
    }];
}
//点击
- (void)popViewClick:(CustomButton *)sender
{
    switch (sender.tag) {
        case 1:
        {
            [self setRemark];
        }
            break;
        case 2:
        {
            [self deleteFriend];
        }
            break;
        case 3:
        {
            [self removeAllMessages:nil];
        }
            break;            
        case 4:
        {
            [self reportClick:nil];
        }
            break;
        default:
            break;
    }
    
    [self dismissCover:nil];
}

//#pragma mark- UIAlertViewDelegate
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1) {
//        NSString * newRemark = [[alertView textFieldAtIndex:0].text trim];
//        if (![self.remark isEqualToString:newRemark]) {
//            [self setRemarkWith:newRemark];
//        }
//    }
//}

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

- (void)myCircleClick:(id)sender
{
    MyCircleListViewController * mclvc = [[MyCircleListViewController alloc] init];
    mclvc.userId                       = self.uid;
    [self pushVC:mclvc];
}

- (void)removeAllMessages:(id)sender
{
 
    EMConversation * conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:[ToolsManager getCommonTargetId:self.otherUser.uid] conversationType:eConversationTypeChat];
    
    [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                            message:NSLocalizedString(@"sureToDelete", @"please make sure to delete")
                    completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                        if (buttonIndex == 1) {
                            [conversation removeAllMessages];
                        }
                    } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                  otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
    
}

- (void)shareClick:(id)sender
{
    [self.shareAlertPopView show];
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
    self.shareBtn.y     = self.signBackView.bottom + 20;
    
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

//获取我创建的圈子
- (void)getCircles
{
    //getMyCircleList
    NSString * path = [kGetMyCircleListPath stringByAppendingFormat:@"?user_id=%ld", self.uid];
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
            NSInteger size = imageModelList.count;
            if (size > 3) {
                size = 3;
            }
            for (int i=0; i<size; i++) {
                ImageModel * image      = imageModelList[i];
                UIImageView * imageView = imageArr[i];
                imageView.hidden        = NO;
                [imageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:image.sub_url]] placeholderImage:[UIImage imageNamed:@"loading_default"]];
            }
            
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
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
- (void)setRemark
{
    AddRemarkViewController * arvc = [[AddRemarkViewController alloc] init];
    arvc.frinedId                  = self.otherUser.uid;
    arvc.remark                    = self.remark;
    [self pushVC:arvc];
    
    [arvc setChangeBlock:^(NSString *remark) {
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
