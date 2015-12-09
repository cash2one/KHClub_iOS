//
//  CircleHomeViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/8.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleHomeViewController.h"
#import "CircleModel.h"
#import "CircleDetailViewController.h"
#import "NewsDetailViewController.h"
#import "OtherPersonalViewController.h"
#import "NewsModel.h"
#import "ImageModel.h"
#import "CommentModel.h"
#import "LikeModel.h"
#import "BrowseImageListViewController.h"
#import "NewsListCell.h"
#import "NewsUtils.h"
#import "CircleMembersViewController.h"
#import "ShareAlertPopView.h"
#import "IMUtils.h"
#import "ShareUtils.h"
#import "CardChooseUserViewController.h"

@interface CircleHomeViewController ()<NewsListDelegate, RefreshDataDelegate>

//需要复制的字符串
@property (nonatomic, copy) NSString * pasteStr;

//圈子图片
@property (nonatomic, strong) CustomImageView * coverImageView;
//背景图
@property (nonatomic, strong) UIView          * backView;
//圈子标题
@property (nonatomic, strong) CustomLabel     * circleTitleLabel;
//圈主
@property (nonatomic, strong) CustomLabel     * circleNameLabel;
//圈友数量
@property (nonatomic, strong) CustomLabel     * circleFansCountLabel;
//关注按钮
@property (nonatomic, strong) CustomButton    * followBtn;
//圈友背景
@property (nonatomic, strong) CustomButton    * circleFansView;
//圈子模型
@property (nonatomic, strong) CircleModel     * circleModel;
//右上角点击分享按钮
@property (nonatomic, strong) ShareAlertPopView * shareAlertPopView;

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
    self.backView             = [[UIView alloc] init];

    self.coverImageView       = [[CustomImageView alloc] init];
    self.circleTitleLabel     = [[CustomLabel alloc] init];
    self.circleNameLabel      = [[CustomLabel alloc] init];
    self.circleFansCountLabel = [[CustomLabel alloc] init];
    self.followBtn            = [[CustomButton alloc] init];
    self.circleFansView       = [[CustomButton alloc] init];

    [self.backView addSubview:self.coverImageView];
    [self.backView addSubview:self.circleTitleLabel];
    [self.backView addSubview:self.circleNameLabel];
    [self.backView addSubview:self.circleFansCountLabel];
    [self.backView addSubview:self.followBtn];
    [self.backView addSubview:self.circleFansView];
    
    //关注事件
    [self.followBtn addTarget:self action:@selector(followPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.circleFansView addTarget:self action:@selector(fansListPress:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.backView.frame                 = CGRectMake(0, 0, self.viewWidth, 160);
    self.backView.backgroundColor       = [UIColor whiteColor];
    self.coverImageView.frame           = CGRectMake(10, 10, 57, 57);
    //关注按钮
    self.followBtn.frame                   = CGRectMake([DeviceManager getDeviceWidth]-80, 30, 60, 30);
    self.followBtn.backgroundColor         = [UIColor colorWithHexString:ColorGold];
    [self.followBtn setTitle:KHClubString(@"News_CircleList_Follow") forState:UIControlStateNormal];
    [self.followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //标题
    self.circleTitleLabel.frame         = CGRectMake(self.coverImageView.right+10, self.coverImageView.y+3, self.viewWidth-self.coverImageView.right-100, 15);
    self.circleTitleLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    //人名
    self.circleNameLabel.frame          = CGRectMake(self.coverImageView.right+10, self.circleTitleLabel.bottom+3, self.viewWidth-self.coverImageView.right-30, 15);
    self.circleNameLabel.textColor      = [UIColor colorWithHexString:ColorDeepBlack];
    //成员数量
    self.circleFansCountLabel.frame     = CGRectMake(self.coverImageView.right+10, self.circleNameLabel.bottom+3, self.viewWidth-self.coverImageView.right-30, 15);
    self.circleFansCountLabel.textColor = [UIColor colorWithHexString:ColorDeepBlack];
    //成员列表
    self.circleFansView.frame           = CGRectMake(0, self.coverImageView.bottom+5, self.viewWidth, 50);
    
    //线
    UIView * lineView                   = [[UIView alloc] initWithFrame:CGRectMake(0, self.circleFansView.bottom, self.viewWidth, 10)];
    lineView.backgroundColor            = [UIColor colorWithHexString:ColorLightGary];
    [self.backView addSubview:lineView];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:@"" andBlock:^{
        [sself.shareAlertPopView show];
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
//                [ShareUtils shareWechatWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertWechatMoment:
            {
//                [ShareUtils shareWechatMomentsWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertSina:
            {
//                [ShareUtils shareSinaWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertQQ:
            {
//                [ShareUtils shareQQWithUser:[UserService sharedService].user];
            }
                break;
            case ShareAlertQzone:
            {
//                [ShareUtils shareQzoneWithUser:[UserService sharedService].user];
            }
                break;
                
            default:
                break;
        }
        
        [sself.shareAlertPopView cancelPop];
    }];
    
    
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
    
    NSString * cellid   = [NSString stringWithFormat:@"%@%ld", @"newsList", indexPath.row];
    NewsListCell * cell = [self.refreshTableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell          = [[NewsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.delegate = self;
    }
    [cell setConentWithModel:self.dataArr[indexPath.row]];
    
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
    return 155;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.coverImageView.image      = [UIImage imageNamed:DEFAULT_AVATAR];
    self.circleTitleLabel.text     = @"标题";
    self.circleNameLabel.text      = @"人名";
    self.circleFansCountLabel.text = @"10000";

    [self.circleFansView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i=1; i<6; i++) {
        CustomImageView * fansImageView   = [[CustomImageView alloc] initWithFrame:CGRectMake(self.viewWidth-i*50, 5, 40, 40)];
        fansImageView.layer.cornerRadius  = 20;
        fansImageView.layer.masksToBounds = YES;
        fansImageView.image               = [UIImage imageNamed:DEFAULT_AVATAR];
        [self.circleFansView addSubview:fansImageView];
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
    debugLog(@"111");
}

- (void)fansListPress:(id)sender
{
    CircleMembersViewController * cmvc = [[CircleMembersViewController alloc] init];
    cmvc.circleId = self.circleId;
    [self pushVC:cmvc];
}


//顶部成员头像点击
- (void)fansAvatarClick:(CustomButton *)sender
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    opvc.uid                           = sender.tag;
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
//    CardChooseUserViewController * ccuvc = [[CardChooseUserViewController alloc] init];
//    
//    NSDictionary * cardDic = @{@"type":[@(eConversationTypeGroupChat) stringValue],
//                               @"id":[NSString stringWithFormat:@"%ld", self.circleId],
//                               @"title":self.circleModel.circle_name,
//                               @"avatar":@""};
//    NSString * cardJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:cardDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//    ccuvc.cardMessage   = [@"###card^card###" stringByReplacingOccurrencesOfString:@"^" withString:cardJson];
//    [self presentViewController:ccuvc animated:YES completion:nil];
}

#pragma mark- private method
- (void)loadAndhandleData
{
    
    //最后一次时间
    NSString * first_time = @"0";
    if (!self.isReloading && self.dataArr.count > 0) {
        NewsModel * news = self.dataArr.firstObject;
        first_time        = news.publish_time;
    }
    
    NSString * url = [NSString stringWithFormat:@"%@?page=%d&user_id=%ld&frist_time=%@", kNewsListPath, self.currentPage, [UserService sharedService].user.uid, first_time];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {

        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
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
    CGSize contentSize        = [ToolsManager getSizeWithContent:news.content_text andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
    if (news.content_text == nil || news.content_text.length < 1) {
        contentSize.height = 0;
    }
    //头像55 评论按钮30 还有10的底线
    NSInteger cellOtherHeight = 55+30+10;
    
    CGFloat height;
    if (news.image_arr.count < 1) {
        //没有图片
        height = cellOtherHeight+contentSize.height+5;
    }else if (news.image_arr.count == 1) {
        //一张图片 大图
        ImageModel * imageModel = news.image_arr[0];
        CGSize size             = CGSizeMake(imageModel.width, imageModel.height);
        CGRect rect             = [NewsUtils getRectWithSize:size];
        height                  = cellOtherHeight+contentSize.height+rect.size.height+10;
    }else{
        //多张图片九宫格
        NSInteger lineNum   = news.image_arr.count/3;
        NSInteger columnNum = news.image_arr.count%3;
        if (columnNum > 0) {
            lineNum++;
        }
        CGFloat itemWidth = [DeviceManager getDeviceWidth]/5.0;
        height            = cellOtherHeight+contentSize.height+lineNum*(itemWidth+10);
    }
    
    //地址
    if (news.location.length > 0) {
        height += 25;
    }
    //点赞列表
    if (news.like_arr.count > 0) {
        CGFloat width = ([DeviceManager getDeviceWidth]-53-27)/8;
        height += width+5;
    }
    
    //评论
    for (int i=0; i<news.comment_arr.count; i++) {
        CommentModel * comment = news.comment_arr[i];
        NSString * commentStr  = [NSString stringWithFormat:@"%@:%@", comment.name, comment.comment_content];
        CGSize nameSize        = [ToolsManager getSizeWithContent:commentStr andFontSize:14 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
        height                 = height + nameSize.height+5;
    }
    
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
