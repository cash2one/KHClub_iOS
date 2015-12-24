//
//  CircleHomeViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/8.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleHomeViewController.h"
#import "PublishNewsViewController.h"
#import "CircleModel.h"
#import "CircleDetailViewController.h"
#import "NewsDetailViewController.h"
#import "OtherPersonalViewController.h"
#import "NewsModel.h"
#import "ImageModel.h"
#import "CommentModel.h"
#import "LikeModel.h"
#import "BrowseImageListViewController.h"
#import "CircleNewsListCell.h"
#import "NewsUtils.h"
#import "CircleMembersViewController.h"
#import "ShareAlertPopView.h"
#import "IMUtils.h"
#import "ShareUtils.h"
#import "UIImageView+WebCache.h"
#import "CardChooseUserViewController.h"
#import "CircleNoticeListViewController.h"

@interface CircleHomeViewController ()<NewsListDelegate, RefreshDataDelegate>

//需要复制的字符串
@property (nonatomic, copy) NSString * pasteStr;

//圈子图片
@property (nonatomic, strong) CustomImageView   * coverImageView;
//背景图
@property (nonatomic, strong) UIView            * backView;
//圈子标题
@property (nonatomic, strong) CustomLabel       * circleTitleLabel;
//圈主
@property (nonatomic, strong) CustomLabel       * circleNameLabel;
//圈友数量
@property (nonatomic, strong) CustomLabel       * circleFansCountLabel;
//关注按钮
@property (nonatomic, strong) CustomButton      * followBtn;
//圈友背景
@property (nonatomic, strong) CustomButton      * circleFansView;
//公告背景
@property (nonatomic, strong) CustomButton      * circleNoticeView;
//公告内容
@property (nonatomic, strong) CustomLabel       * noticeLabel;
//圈子模型
@property (nonatomic, strong) CircleModel       * circleModel;
//公告内容
@property (nonatomic, copy)   NSString          * noticeContent;
//成员列表
@property (nonatomic, strong) NSMutableArray    * membersArray;
//右上角点击分享按钮
@property (nonatomic, strong) ShareAlertPopView * shareAlertPopView;
//发布按钮
@property (nonatomic, strong) CustomButton      * publishBtn;

@end

@implementation CircleHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWidget];
    [self configUI];
    
    [self refreshData];
    [self registerNotify];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- layout
- (void)initWidget
{
    self.membersArray         = [[NSMutableArray alloc] init];
    self.circleModel          = [[CircleModel alloc] init];
    self.backView             = [[UIView alloc] init];

    self.coverImageView       = [[CustomImageView alloc] init];
    self.circleTitleLabel     = [[CustomLabel alloc] init];
    self.circleNameLabel      = [[CustomLabel alloc] init];
    self.circleFansCountLabel = [[CustomLabel alloc] init];
    self.followBtn            = [[CustomButton alloc] init];
    self.circleFansView       = [[CustomButton alloc] init];
    self.circleNoticeView     = [[CustomButton alloc] init];
    self.noticeLabel          = [[CustomLabel alloc] init];
    self.publishBtn           = [[CustomButton alloc] init];
    
    [self.backView addSubview:self.coverImageView];
    [self.backView addSubview:self.circleTitleLabel];
    [self.backView addSubview:self.circleNameLabel];
    [self.backView addSubview:self.circleFansCountLabel];
    [self.backView addSubview:self.followBtn];
    [self.backView addSubview:self.circleFansView];
    [self.backView addSubview:self.circleNoticeView];
    [self.circleNoticeView addSubview:self.noticeLabel];
    [self.view addSubview:self.publishBtn];
    
    //关注事件
    [self.followBtn addTarget:self action:@selector(followPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.circleFansView addTarget:self action:@selector(fansListPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.circleNoticeView addTarget:self action:@selector(noticeListPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headBackClick)];
    [self.backView addGestureRecognizer:tap];
}

//重写tableView
- (void)createRefreshView
{
    self.refreshTableView                 = [[RefreshTableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight) style:UITableViewStyleGrouped];
    self.refreshTableView.delegate        = self;
    self.refreshTableView.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];
    self.refreshTableView.dataSource      = self;
    self.refreshTableView.refreshDelegate = self;
    self.refreshTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [self.refreshTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)]];
    
    [self.view addSubview:self.refreshTableView];
}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"News_CircleList_CircleHome")];
    
    self.backView.frame                     = CGRectMake(0, 0, self.viewWidth, 135);
    self.backView.backgroundColor           = [UIColor whiteColor];
    self.coverImageView.frame               = CGRectMake(10, 20, 57, 57);
    self.coverImageView.layer.cornerRadius  = 3;
    self.coverImageView.layer.masksToBounds = YES;

    //标题
    self.circleTitleLabel.frame             = CGRectMake(self.coverImageView.right+10, self.coverImageView.y, self.viewWidth-self.coverImageView.right-100, 13);
    self.circleTitleLabel.font              = [UIFont systemFontOfSize:13];
    //人名
    self.circleNameLabel.frame              = CGRectMake(self.coverImageView.right+10, self.circleTitleLabel.bottom+6, self.viewWidth-self.coverImageView.right-30, 13);
    self.circleNameLabel.font               = [UIFont systemFontOfSize:13];
    //成员数量图片
    CustomImageView * countImageView        = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"member"]];
    countImageView.frame                    = CGRectMake(self.coverImageView.right+10, self.circleNameLabel.bottom+6, 15, 15);
    //成员列表
    self.circleFansView.frame               = CGRectMake(0, self.coverImageView.bottom+5, self.viewWidth, 30);
    self.circleNoticeView.frame             = CGRectMake(0, self.circleFansView.bottom, self.viewWidth, 30);
    
    //圈达人图标
    CustomImageView * noticeImageView = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"members_cover"]];
    noticeImageView.frame             = CGRectMake(self.coverImageView.x, 10, 20, 20);
    //圈达人标题
    CustomLabel * noticeTitleLabel    = [[CustomLabel alloc] initWithFontSize:12];
    noticeTitleLabel.textColor        = [UIColor colorWithHexString:ColorDeepBlack];
    noticeTitleLabel.frame            = CGRectMake(noticeImageView.right+5, 14, 50, 12);
    noticeTitleLabel.text             = KHClubString(@"Circle_Circle_CircleMember");
    //内容
    self.noticeLabel.frame            = CGRectMake(noticeTitleLabel.right+5, 0, self.viewWidth-noticeTitleLabel.right-15, 40);
    self.noticeLabel.font             = [UIFont systemFontOfSize:15];
    self.noticeLabel.lineBreakMode    = NSLineBreakByTruncatingTail;
    [self.circleNoticeView addSubview:noticeImageView];
    [self.circleNoticeView addSubview:noticeTitleLabel];
    
    //成员数量
    self.circleFansCountLabel.frame         = CGRectMake(countImageView.right+5, self.circleNameLabel.bottom+7, self.viewWidth-self.coverImageView.right-30, 13);
    self.circleFansCountLabel.font          = [UIFont systemFontOfSize:13];

    //关注按钮
    self.followBtn.frame                    = CGRectMake([DeviceManager getDeviceWidth]-75, 39, 60, 22);
    [self.followBtn setTitle:KHClubString(@"News_CircleList_Follow") forState:UIControlStateNormal];
    [self.followBtn setTitleColor:[UIColor colorWithHexString:ColorGold] forState:UIControlStateNormal];
    self.followBtn.layer.cornerRadius       = 3;
    self.followBtn.layer.borderColor        = [UIColor colorWithHexString:ColorGold].CGColor;
    self.followBtn.titleLabel.font          = [UIFont systemFontOfSize:13];
    self.followBtn.layer.borderWidth        = 1;
    self.followBtn.hidden                   = YES;
    //线
    UIView * lineView                       = [[UIView alloc] initWithFrame:CGRectMake(0, self.circleNoticeView.bottom+8, self.viewWidth, 5)];
    lineView.backgroundColor                = [UIColor colorWithHexString:ColorLightGary];
    [self.backView addSubview:lineView];
    [self.backView addSubview:countImageView];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:@"" andBlock:^{
        [sself.shareAlertPopView show];
    }];
    
    self.navBar.rightBtn.imageEdgeInsets             = UIEdgeInsetsMake(0, 15, 0, 0);
    self.navBar.rightBtn.imageView.contentMode       = UIViewContentModeScaleAspectFit;
    //名片和设置
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"personal_more"] forState:UIControlStateNormal];
    
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
                [ShareUtils shareWechatWithTitle:sself.circleModel.circle_name andManagerName:sself.circleModel.manager_name andImage:sself.circleModel.circle_cover_sub_image andCircleID:sself.circleId];
            }
                break;
            case ShareAlertWechatMoment:
            {
                [ShareUtils shareWechatMomentsWithTitle:sself.circleModel.circle_name andManagerName:sself.circleModel.manager_name andImage:sself.circleModel.circle_cover_sub_image andCircleID:sself.circleId];
            }
                break;
            case ShareAlertSina:
            {
            }
                break;
            case ShareAlertQQ:
            {
                [ShareUtils shareQQWithTitle:sself.circleModel.circle_name andManagerName:sself.circleModel.manager_name andImage:sself.circleModel.circle_cover_sub_image andCircleID:sself.circleId];
            }
                break;
            case ShareAlertQzone:
            {
                [ShareUtils shareQzoneWithTitle:sself.circleModel.circle_name andManagerName:sself.circleModel.manager_name andImage:sself.circleModel.circle_cover_sub_image andCircleID:sself.circleId];
            }
                break;
                
            default:
                break;
        }
        
        [sself.shareAlertPopView cancelPop];
    }];
    
    if (self.isCreate) {
        //从创建页面进来的
        [self.navBar setLeftBtnWithContent:@"" andBlock:^{
            [sself popToTabBarViewController];
        }];
    }
    
    //发布按钮
    self.publishBtn.frame  = CGRectMake(self.viewWidth-60, self.viewHeight-60, 30, 30);
    self.publishBtn.hidden = YES;
    [self.publishBtn setImage:[UIImage imageNamed:@"publish_news_big"] forState:UIControlStateNormal];
    [self.publishBtn addTarget:self action:@selector(publishClick:) forControlEvents:UIControlEventTouchUpInside];

}

#pragma mark- override
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//下拉刷新
- (void)refreshData
{
    [super refreshData];
    [self loadAndhandleData];
}
//加载更多
- (void)loadingData
{
    [super loadingData];
    [self loadAndhandleData];
}

#pragma mark- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * cellid         = [NSString stringWithFormat:@"%@%ld", @"newsList", indexPath.row];
    CircleNewsListCell * cell = [self.refreshTableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell          = [[CircleNewsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.delegate = self;
    }
    NewsModel * news = self.dataArr[indexPath.row];
    [cell setContentWithModel:news withIsManager:news.uid == self.circleModel.managerId];
    
    return cell;
}

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsDetailViewController * ndvc = [[NewsDetailViewController alloc] init];
    NewsModel * news                = self.dataArr[indexPath.row];
    ndvc.newsId                     = news.nid;
    [self pushVC:ndvc];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsModel * news          = self.dataArr[indexPath.row];
    
    return [self getCellHeightWith:news];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 165;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    //顶部UI刷新
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:self.circleModel.circle_cover_sub_image]] placeholderImage:[UIImage imageNamed:@"loading_default"]];
    self.circleTitleLabel.text     = [KHClubString(@"Circle_Circle_CircleName") stringByAppendingString:[ToolsManager emptyReturnNone:self.circleModel.circle_name]];
    self.circleNameLabel.text      = [NSString stringWithFormat:@"%@：%@",KHClubString(@"Circle_Circle_CircleManager"), [ToolsManager emptyReturnNone:self.circleModel.manager_name]];
    //圈子存在
    if (self.circleModel.cid > 0) {
        self.circleFansCountLabel.text = [NSString stringWithFormat:@"%ld", self.circleModel.follow_quantity];
    }

    [self.circleFansView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //圈达人图标
    CustomImageView * memberImageView = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"members_cover"]];
    memberImageView.frame             = CGRectMake(self.coverImageView.x, 10, 20, 20);
    //圈达人标题
    CustomLabel * memberTitleLabel    = [[CustomLabel alloc] initWithFontSize:12];
    memberTitleLabel.textColor        = [UIColor colorWithHexString:ColorDeepBlack];
    memberTitleLabel.frame            = CGRectMake(memberImageView.right+5, 14, 50, 12);
    memberTitleLabel.text             = KHClubString(@"Circle_Circle_CircleMember");
    [self.circleFansView addSubview:memberImageView];
    [self.circleFansView addSubview:memberTitleLabel];
    
    //公告
    self.noticeLabel.text  = self.noticeContent;
    
    NSInteger membersCount = self.membersArray.count;
    if (membersCount > 5) {
        membersCount = 5;
    }
    
    for (int i=0; i<membersCount; i++) {
        UserModel * model = self.membersArray[i];
        CustomImageView * fansImageView      = [[CustomImageView alloc] initWithFrame:CGRectMake(85+i*35, 5, 30, 30)];
        fansImageView.layer.cornerRadius     = 15;
        fansImageView.layer.masksToBounds    = YES;
        fansImageView.userInteractionEnabled = YES;
        fansImageView.tag                    = model.uid;
        //点击事件
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fansAvatarClick:)];
        [fansImageView addGestureRecognizer:tap];
        
        [fansImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:model.head_sub_image]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
        [self.circleFansView addSubview:fansImageView];
    }
    
    //关注按钮处理
    if (self.circleModel.managerId != 0) {
        if (self.circleModel.managerId == [UserService sharedService].user.uid) {
            self.followBtn.hidden = YES;
        }else{
            self.followBtn.hidden = NO;
            if (self.circleModel.isFollow) {
                [self.followBtn setTitle:KHClubString(@"News_CircleList_Unfollow") forState:UIControlStateNormal];
            }else{
                [self.followBtn setTitle:KHClubString(@"News_CircleList_Follow") forState:UIControlStateNormal];
            }
        }
    }
    
    return self.backView;
}

#pragma mark- NewsListDelegate
- (void)longPressContent:(NewsModel *)news andGes:(UILongPressGestureRecognizer *)ges
{
    [self becomeFirstResponder];
    self.pasteStr                    = news.content_text;
    UIView * view                    = ges.view;
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem * copyItem            = [[UIMenuItem alloc] initWithTitle:KHClubString(@"Common_Copy") action:@selector(copyContnet)];
    UIMenuItem * cancelItem          = [[UIMenuItem alloc] initWithTitle:StringCommonCancel action:@selector(cancel)];
    [menuController setMenuItems:@[copyItem,cancelItem]];
    [menuController setArrowDirection:UIMenuControllerArrowDown];
    [menuController setTargetRect:view.frame inView:view.superview];
    [menuController setMenuVisible:YES animated:YES];
}

//图片点击
- (void)imageClick:(NewsModel *)news index:(NSInteger)index
{
    
    BrowseImageListViewController * bilvc = [[BrowseImageListViewController alloc] init];
    bilvc.num                             = index;
    bilvc.dataSource                      = news.image_arr;
    [self presentViewController:bilvc animated:YES completion:nil];
    
}

//发送评论
- (void)sendCommentClick:(NewsModel *)news
{
    NewsDetailViewController * ndvc = [[NewsDetailViewController alloc] init];
    ndvc.newsId                     = news.nid;
    [self pushVC:ndvc];
}
//点赞
- (void)likeClick:(NewsModel *)news likeOrCancel:(BOOL)flag
{
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"news_id":[NSString stringWithFormat:@"%ld", news.nid],
                              @"isLike":[NSString stringWithFormat:@"%d", flag],
                              @"is_second":@"0"};
    //成功失败都没反应
    [HttpService postWithUrlString:kLikeOrCancelPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


#pragma mark- method response
//复制
- (void)copyContnet
{
    //得到剪切板
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string        = self.pasteStr;
    self.pasteStr       = @"";
    debugLog(@"%@",[UIPasteboard generalPasteboard].string);
}
//取消menu
- (void)cancel
{}

- (void)followPress:(id)sender
{
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"circle_id":[NSString stringWithFormat:@"%ld", self.circleId],
                              @"isFollow":[NSString stringWithFormat:@"%d", !self.circleModel.isFollow]};
    debugLog(@"%@ %@", kFollowOrUnfollowCirclePath, params);
    [self showLoading:StringCommonUploadData];
    //成功失败都没反应
    [HttpService postWithUrlString:kFollowOrUnfollowCirclePath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self hideLoading];
            //修改
            if (self.circleModel.isFollow) {
                [self.followBtn setTitle:KHClubString(@"News_CircleList_Follow") forState:UIControlStateNormal];
                self.circleModel.isFollow = NO;
                self.publishBtn.hidden    = YES;
            }else{
                [self.followBtn setTitle:KHClubString(@"News_CircleList_Unfollow") forState:UIControlStateNormal];
                self.circleModel.isFollow = YES;
                self.publishBtn.hidden     = NO;
            }
            //通知
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CIRCLE_LIST object:nil];
        }else{
            [self showWarn:StringCommonUploadDataFail];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

- (void)fansListPress:(id)sender
{
    CircleMembersViewController * cmvc = [[CircleMembersViewController alloc] init];
    cmvc.circleId = self.circleId;
    [self pushVC:cmvc];
}

- (void)noticeListPress:(id)sender
{
    CircleNoticeListViewController * cnlv = [[CircleNoticeListViewController alloc] init];
    cnlv.circleID                         = self.circleId;
    cnlv.isManager                        = self.circleModel.managerId == [UserService sharedService].user.uid;
    [self pushVC:cnlv];
}

//顶部成员头像点击
- (void)fansAvatarClick:(UITapGestureRecognizer *)sender
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    opvc.uid                           = sender.view.tag;
    [self pushVC:opvc];
}
//顶部背景点击 进入圈子详情
- (void)headBackClick
{
    CircleDetailViewController * cdvc = [[CircleDetailViewController alloc] init];
    cdvc.circleModel                  = self.circleModel;
    [self pushVC:cdvc];
}

- (void)sendToFriend
{
    CardChooseUserViewController * ccuvc = [[CardChooseUserViewController alloc] init];
    
    NSDictionary * cardDic = @{@"type":[@(100) stringValue],
                               @"id":[NSString stringWithFormat:@"%ld", self.circleId],
                               @"title":self.circleModel.circle_name,
                               @"avatar":[ToolsManager completeUrlStr:self.circleModel.circle_cover_sub_image]};
    NSString * cardJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:cardDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    ccuvc.cardMessage   = [@"###card^card###" stringByReplacingOccurrencesOfString:@"^" withString:cardJson];
    [self presentViewController:ccuvc animated:YES completion:nil];
}

#pragma mark- private method
- (void)publishClick:(id)sender
{
    PublishNewsViewController * pnvc = [[PublishNewsViewController alloc] init];
    pnvc.returnVC                    = self;
    [self pushVC:pnvc];
}
- (void)loadAndhandleData
{
    
    //最后一次时间
    NSString * first_time = @"0";
    if (!self.isReloading && self.dataArr.count > 0) {
        NewsModel * news = self.dataArr.firstObject;
        first_time        = news.publish_time;
    }
    
    NSString * url = [NSString stringWithFormat:@"%@?page=%d&circle_id=%ld&user_id=%ld&frist_time=%@", kGetCircleHomeListPath, self.currentPage, self.circleId, [UserService sharedService].user.uid, first_time];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {

        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            if (self.currentPage <= 1) {
                //获取内容
                [self.membersArray removeAllObjects];
                NSArray * circleMembers = responseData[HttpResult][@"circleMembers"];
                //成员列表
                for (NSDictionary * member in circleMembers) {
                    UserModel * memberUser    = [[UserModel alloc] init];
                    memberUser.uid            = [member[@"id"] integerValue];
                    memberUser.head_sub_image = member[@"head_sub_image"];
                    [self.membersArray addObject:memberUser];
                }
                //圈子模型注入
                NSDictionary * cicleDic                 = responseData[HttpResult][@"circle"];
                self.circleModel.cid                    = [cicleDic[@"id"] integerValue];
                self.circleModel.address                = cicleDic[@"address"];
                self.circleModel.circle_cover_image     = cicleDic[@"circle_cover_image"];
                self.circleModel.circle_cover_sub_image = cicleDic[@"circle_cover_sub_image"];
                self.circleModel.circle_detail          = cicleDic[@"circle_detail"];
                self.circleModel.circle_name            = cicleDic[@"circle_name"];
                self.circleModel.circle_web             = cicleDic[@"circle_web"];
                self.circleModel.isFollow               = [cicleDic[@"is_follow"] boolValue];
                self.circleModel.wx_num                 = cicleDic[@"wx_num"];
                self.circleModel.wx_qrcode              = cicleDic[@"wx_qrcode"];
                self.circleModel.manager_name           = cicleDic[@"name"];
                self.circleModel.phone_num              = cicleDic[@"phone_num"];
                self.circleModel.managerId              = [cicleDic[@"user_id"] integerValue];
                self.circleModel.follow_quantity        = [cicleDic[@"follow_quantity"] integerValue];
            }
            
            if (self.circleModel.isFollow) {
                self.publishBtn.hidden = NO;
            }else{
                self.publishBtn.hidden = YES;
            }
            
            //下拉刷新清空数组
            if (self.isReloading) {
                [self.dataArr removeAllObjects];
            }
            self.isLastPage = [responseData[HttpResult][@"is_last"] boolValue];
            NSArray * list = responseData[HttpResult][HttpList];
            //注入数据刷新页面
            [self injectDataSourceWith:list];
            
        }else{
            self.isReloading = NO;
            [self.refreshTableView refreshFinish];
            [self showWarn:StringCommonNetException];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.isReloading = NO;
        [self.refreshTableView refreshFinish];
        [self showWarn:StringCommonNetException];
    }];
    
}

//数据注入
- (void)injectDataSourceWith:(NSArray *)list
{
    //数据处理
    for (NSDictionary * newsDic in list) {
        NewsModel * news      = [[NewsModel alloc] init];
        [news setContentWithDic:newsDic];
        [self.dataArr addObject:news];
    }
    
    [self reloadTable];
}

//注册通知
- (void)registerNotify
{
    //刷新页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNewsPublish:) name:NOTIFY_PUBLISH_NEWS object:nil];
}

//新消息发布成功刷新页面
- (void)newNewsPublish:(NSNotification *)notify
{
    self.refreshTableView.contentOffset = CGPointZero;
    [self refreshData];
}

- (CGFloat)getCellHeightWith:(NewsModel *)news
{
    //总长
    CGFloat height;
    //头像65
    NSInteger imageHeight = 65;
    height                = imageHeight;
    
    CGSize contentSize    = [ToolsManager getSizeWithContent:news.content_text andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-150, MAXFLOAT)];
    if (news.content_text == nil || news.content_text.length < 1) {
        contentSize.height = 0;
    }else if (contentSize.height <= 20) {
        contentSize.height = 18;
    }else if (contentSize.height > 20) {
        contentSize.height = 36;
    }
    //有内容
    if (contentSize.height > 0) {
        height += contentSize.height+20;
    }
    
    if (news.image_arr.count == 1) {
        //一张图片 大图
        ImageModel * imageModel = news.image_arr[0];
        CGSize size             = CGSizeMake(imageModel.width, imageModel.height);
        CGRect rect             = [NewsUtils getRectWithSize:size];
        height                  += rect.size.height+15;
    }else if(news.image_arr.count > 1){
        //多张图片九宫格
        NSInteger lineNum   = news.image_arr.count/3;
        NSInteger columnNum = news.image_arr.count%3;
        if (columnNum > 0) {
            lineNum++;
        }
        CGFloat itemWidth = ([DeviceManager getDeviceWidth]-100) / 3;
        height            += lineNum*(itemWidth+10)+15-10;
    }
    
    //时间
    height += 27;
    
    //地址
    if (news.location.length > 0) {
        height += 22;
    }
    //圈子
    if (news.circle_arr.count > 0) {
        height += 22;
    }
    
    //底部操作栏
    height += 45;
    return height;
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
