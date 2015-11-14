//
//  MyNewsListViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/23.
//  Copyright (c) 2015年 JLXC. All rights reserved.

#import "MyNewsListViewController.h"
#import "NewsDetailViewController.h"
#import "PublishNewsViewController.h"
#import "NewsModel.h"
#import "ImageModel.h"
#import "CommentModel.h"
#import "LikeModel.h"
#import "BrowseImageListViewController.h"
#import "MyNewsListCell.h"
#import "HttpCache.h"
#import "NewsUtils.h"
#import "NotifyNewsViewController.h"

@interface MyNewsListViewController ()<MyNewsListDelegate>

//需要复制的字符串
@property (nonatomic, copy) NSString * pasteStr;

@end

@implementation MyNewsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshTableView.frame = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    
    [self initWidget];
    [self configUI];
    
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)initWidget
{

}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"Personal_MyNews_PersonalNews")];
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
    NewsDetailViewController * ndvc = [[NewsDetailViewController alloc] init];
    NewsModel * news                = self.dataArr[indexPath.row];
    ndvc.newsId                     = news.nid;
    [self pushVC:ndvc];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * cellid     = [NSString stringWithFormat:@"%@%ld", @"newsList", indexPath.row];
    MyNewsListCell * cell = [self.refreshTableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell          = [[MyNewsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.delegate = self;
    }
    
    [cell setConentWithModel:self.dataArr[indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsModel * news          = self.dataArr[indexPath.row];
    
    return [self getCellHeightWith:news];
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
    //news_id=23&user_id=1&is_second=0&isLike=1
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"news_id":[NSString stringWithFormat:@"%ld", news.nid],
                              @"isLike":[NSString stringWithFormat:@"%d", flag],
                              @"is_second":@"0"};
    debugLog(@"%@ %@", kLikeOrCancelPath, params);
    
    //成功失败都没反应
    [HttpService postWithUrlString:kLikeOrCancelPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        //        debugLog(@"%@", responseData);
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

    NSString * url;
    if (self.isOther) {
        url = [NSString stringWithFormat:@"%@?page=%d&user_id=%ld", kUserNewsListPath, self.currentPage, self.uid];
    }else{
        url = [NSString stringWithFormat:@"%@?page=%d&user_id=%ld", kUserNewsListPath, self.currentPage, [UserService sharedService].user.uid];
    }
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
    for (NSDictionary * newsDic in list) {
        NewsModel * news      = [[NewsModel alloc] init];
        [news setContentWithDic:newsDic];
        [self.dataArr addObject:news];
    }
    
    [self reloadTable];
}

- (CGFloat)getCellHeightWith:(NewsModel *)news
{
    CGSize contentSize        = [ToolsManager getSizeWithContent:news.content_text andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
    if (news.content_text == nil || news.content_text.length < 1) {
        contentSize.height = 0;
    }
    //时间28 评论按钮30 还有10的底线
    NSInteger cellOtherHeight = 28+30+10;
    
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
