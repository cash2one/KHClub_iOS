//
//  NotifyNewsViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/6/25.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "NotifyNewsViewController.h"
#import "NewsPushModel.h"
#import "NewsPushCell.h"
#import "NewsDetailViewController.h"
#import "CircleNoticeDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface NotifyNewsViewController ()

//好友列表
@property (nonatomic, strong) UITableView    * pushTableView;
//好友数据源
@property (nonatomic, strong) NSMutableArray * dataArr;
//新的朋友请求数组
@property (nonatomic, strong) NSMutableArray * recentFriendsArr;
//没有点进添加列表看的新朋友
@property (nonatomic ,assign) NSInteger      unReadNum;
//页数
@property (nonatomic, assign) NSInteger      page;
//尺寸
@property (nonatomic, assign) NSInteger      size;

@end

@implementation NotifyNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.size = 30;
    
    //初始化列表
    [self initTable];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [NewsPushModel setIsRead];
    //顶部消息通知未读提示更新
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_NEWS_PUSH object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TAB_BADGE object:nil];
    [self refreshData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout

- (void)configUI
{
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:KHClubString(@"News_NotifyNews_Clear") andBlock:^{
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:StringCommonPrompt message:KHClubString(@"News_NotifyNews_SureClearPrompt") delegate:sself cancelButtonTitle:StringCommonCancel otherButtonTitles:StringCommonConfirm, nil];
        [alert show];
        
    }];
    
    [self setNavBarTitle:KHClubString(@"News_NotifyNews_Title")];
}

- (void)initTable
{
    self.dataArr                       = [[NSMutableArray alloc] init];

    self.pushTableView                 = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, [DeviceManager getDeviceWidth], [DeviceManager getDeviceHeight]-kNavBarAndStatusHeight) style:UITableViewStylePlain];
    self.pushTableView.delegate        = self;
    self.pushTableView.dataSource      = self;
    self.pushTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.pushTableView.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];
    [self.view addSubview:self.pushTableView];
}

#pragma mark- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellId = [NSString stringWithFormat:@"pushNews%ld", indexPath.row];
    
    NewsPushCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[NewsPushCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NewsPushModel * push = self.dataArr[indexPath.row];
    [cell setContentWithModel:push];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NewsPushModel * push = self.dataArr[indexPath.row];
    [push remove];
    [self.dataArr removeObject:push];
    [self.pushTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

    return YES;
}

#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NewsPushModel * model = self.dataArr[indexPath.row];
    NSString * content = model.comment_content;
    if (model.type == PushLikeNews) {
        //内容
        content = KHClubString(@"News_NotifyNews_LikeTitle");
    }
    //动态修改content
    CGSize contentSize       = [ToolsManager getSizeWithContent:content andFontSize:13 andFrame:CGRectMake(0, 0, [DeviceManager getDeviceWidth]-140, 100)];
    if (contentSize.height < 20) {
        contentSize.height = 20;
    }
    
    return 55.0f+contentSize.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsPushModel * news            = self.dataArr[indexPath.row];
    if (news.type == PushNoticeComment) {
        CircleNoticeDetailViewController * cndvc = [[CircleNoticeDetailViewController alloc] init];
        cndvc.noticeID                           = news.news_id;
        [self pushVC:cndvc];
        return;
    }
    
    NewsDetailViewController * ndvc = [[NewsDetailViewController alloc] init];
    ndvc.newsId                     = news.news_id;
    [self pushVC:ndvc];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArr.count > 0) {
        if (indexPath.row == self.dataArr.count-1) {
            self.page++;
            NSMutableArray * array = [NewsPushModel findWithPage:self.page size:self.size];
            if (array.count < 1) {
                return;
            }
            [self.dataArr addObjectsFromArray:array];
            [self.pushTableView reloadData];
        }
    }

}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [NewsPushModel removeAll];
        
        [self refreshData];
    }
}

#pragma mark- private method
- (void)refreshData
{
    if (self.dataArr.count > 0) {
        [self.dataArr removeAllObjects];
    }
    self.page = 1;
    [self.dataArr addObjectsFromArray:[NewsPushModel findWithPage:self.page size:self.size]];
    [self.pushTableView reloadData];
    
    //徽标跟新
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TAB_BADGE object:nil];
    
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
