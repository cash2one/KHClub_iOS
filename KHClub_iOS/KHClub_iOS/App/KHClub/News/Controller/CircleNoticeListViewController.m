//
//  CircleNoticeListViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleNoticeListViewController.h"
#import "CircleNoticeDetailViewController.h"
#import "LikeModel.h"
#import "CircleNoticeModel.h"
#import "CircleNoticeCell.h"
#import "PublishCircleNoticeViewController.h"

@interface CircleNoticeListViewController ()<CircleNoticeDelegate>

//需要复制的字符串
@property (nonatomic, copy) NSString * pasteStr;

@end

@implementation CircleNoticeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    
    [self refreshData];
    [self registerNotify];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- layout
- (void)configUI
{
    
    if (self.isManager) {
        
        //右上角发布
        __weak typeof(self) sself = self;
        [self.navBar setRightBtnWithContent:@"" andBlock:^{
            PublishCircleNoticeViewController * pcnv = [[PublishCircleNoticeViewController alloc] init];
            pcnv.circleID                            = sself.circleID;
            [sself pushVC:pcnv];
        }];
        
        self.navBar.rightBtn.imageEdgeInsets       = UIEdgeInsetsMake(12, 26, 12, 0);
        self.navBar.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.navBar.rightBtn setImage:[UIImage imageNamed:@"news_publish_normal"] forState:UIControlStateNormal];
    }
    
    [self setNavBarTitle:KHClubString(@"News_PublishCircleNotice_Title")];
    
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

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CircleNoticeModel * notice               = self.dataArr[indexPath.row];
    CircleNoticeDetailViewController * pcnvc = [[CircleNoticeDetailViewController alloc] init];
    pcnvc.noticeID                           = notice.nid;
    [self pushVC:pcnvc];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * cellid       = [NSString stringWithFormat:@"%@%ld", @"newsList", indexPath.row];
    CircleNoticeCell * cell = [self.refreshTableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell          = [[CircleNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.delegate = self;
    }
    [cell setContentWithModel:self.dataArr[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CircleNoticeModel * notice = self.dataArr[indexPath.row];
    
    return [self getCellHeightWith:notice];
}

#pragma mark- NewsListDelegate
- (void)longPressContent:(CircleNoticeModel *)news andGes:(UILongPressGestureRecognizer *)ges
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

//发送评论
- (void)sendCommentClick:(CircleNoticeModel *)news
{

}
//点赞
- (void)likeClick:(CircleNoticeModel *)notice likeOrCancel:(BOOL)flag
{
    //news_id=23&user_id=1&is_second=0&isLike=1
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"notice_id":[NSString stringWithFormat:@"%ld", notice.nid],
                              @"isLike":[NSString stringWithFormat:@"%d", flag]};
    
    //成功失败都没反应
    [HttpService postWithUrlString:kNoticeLikeOrCancelPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
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

#pragma mark- private method
- (void)loadAndhandleData
{
    
    NSString * url = [NSString stringWithFormat:@"%@?page=%d&user_id=%ld&circle_id=%ld", kGetNoticeListPath, self.currentPage, [UserService sharedService].user.uid, self.circleID];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        //        debugLog(@"%@", responseData);
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
    for (NSDictionary * noticeDic in list) {
        
        CircleNoticeModel * notice = [[CircleNoticeModel alloc] init];
        notice.content_text        = noticeDic[@"content_text"];
        notice.nid                 = [noticeDic[@"id"] integerValue];
        notice.publish_date        = noticeDic[@"add_date"];
        notice.comment_quantity    = [noticeDic[@"comment_quantity"] integerValue];
        notice.like_quantity       = [noticeDic[@"like_quantity"] integerValue];
        notice.is_like             = [noticeDic[@"is_like"] boolValue];
        
        [self.dataArr addObject:notice];
    }
    
    [self reloadTable];
}

//注册通知
- (void)registerNotify
{
    //刷新页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNewsPublish:) name:NOTIFY_PUBLISH_NOTICE object:nil];
}

//新消息发布成功刷新页面
- (void)newNewsPublish:(NSNotification *)notify
{
    self.refreshTableView.contentOffset = CGPointZero;
    [self refreshData];
}

- (CGFloat)getCellHeightWith:(CircleNoticeModel *)notice
{
    
    NSMutableParagraphStyle * para = [[NSMutableParagraphStyle alloc] init];
    para.lineBreakMode             = NSLineBreakByCharWrapping;
    para.lineSpacing               = 10;
    NSDictionary * dic             = @{NSFontAttributeName : [UIFont systemFontOfSize:FontListContent],
                                       NSParagraphStyleAttributeName : para};
    CGRect rect                    = [notice.content_text boundingRectWithSize:CGSizeMake(self.viewWidth-20, 45) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    
    //总长
    return rect.size.height+10+27+45;
    
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
