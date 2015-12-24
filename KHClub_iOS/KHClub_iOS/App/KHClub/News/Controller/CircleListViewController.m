//
//  CircleListViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/30.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleListViewController.h"
#import "CircleHomeViewController.h"
#import "CircleModel.h"
#import "CircleCell.h"

@interface CircleListViewController ()<CircleListDelegate>

/**
 *  已关注的圈子
 */
@property (nonatomic, strong) NSMutableArray * followArray;

@end

@implementation CircleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化
    self.followArray = [[NSMutableArray alloc] init];
    //处理继承table
    self.refreshTableView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight-kTabBarHeight);
    [self refreshData];
    self.refreshTableView.footLabel.hidden             = YES;
    self.refreshTableView.showsVerticalScrollIndicator = NO;

    [self registerNotify];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma override
//下拉刷新
- (void)refreshData
{
    [super refreshData];
    [self loadAndhandleData];
}
//加载更多
- (void)loadingData
{
//    [super loadingData];
//    [self loadAndhandleData];
}

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CircleHomeViewController * cdvc = [[CircleHomeViewController alloc] init];
    CircleModel * circle            = nil;
    
    if (indexPath.section == 0) {
        circle = self.followArray[indexPath.row];
    }else{
        circle = self.dataArr[indexPath.row];
    }
    //圈子ID
    cdvc.circleId = circle.cid;
    [self pushVC:cdvc];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.followArray.count < 1) {
            return 0;
        }
    }else{
        if (self.dataArr.count < 1) {
            return 0;
        }
    }
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * backView        = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 30)];
    backView.backgroundColor = [UIColor colorWithHexString:ColorLightGary];
    
    CustomLabel * titleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
    titleLabel.font          = [UIFont systemFontOfSize:14];
    titleLabel.textColor     = [UIColor colorWithHexString:ColorGold];
    if (section == 0) {
        if (self.followArray.count < 1) {
            titleLabel.hidden = YES;
        }else{
            titleLabel.hidden = NO;
        }
        titleLabel.text = KHClubString(@"News_CircleList_MyCircle");
    }else{
        if (self.dataArr.count < 1) {
            titleLabel.hidden = YES;
        }else{
            titleLabel.hidden = NO;
        }
        titleLabel.text = KHClubString(@"News_CircleList_RecommendCircle");
    }
    
    [backView addSubview:titleLabel];
    return backView;
}


#pragma mark- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.followArray.count;
    }else{
        return self.dataArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellid = [@"circleList" stringByAppendingFormat:@"%ld", indexPath.row];
    CircleCell * cell = [self.refreshTableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell          = [[CircleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.delegate = self;
    }
    //关注的
    if (indexPath.section == 0) {
        [cell setContentWithModel:self.followArray[indexPath.row]];
    }else{
        [cell setContentWithModel:self.dataArr[indexPath.row]];
    }
    
    return cell;
}

#pragma mark- CircleListDelegate
//关注点击 布局变换
- (void)followCirclePress:(CircleModel *)model
{
    
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"circle_id":[NSString stringWithFormat:@"%ld", model.cid],
                              @"isFollow":[NSString stringWithFormat:@"%d", !model.isFollow]};
    debugLog(@"%@ %@", kFollowOrUnfollowCirclePath, params);
    [self showLoading:StringCommonUploadData];
    //成功失败都没反应
    [HttpService postWithUrlString:kFollowOrUnfollowCirclePath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self hideLoading];
            //修改
            if (model.isFollow) {
                //这个页面不提供取消关注功能
                model.isFollow = NO;
            }else{
                model.isFollow = YES;
                [self.followArray insertObject:model atIndex:0];
                [self.dataArr removeObject:model];
                [self.refreshTableView reloadData];
            }
            
        }else{
            [self showWarn:StringCommonUploadDataFail];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
    
}

#pragma mark- method response

#pragma mark- private method
//注册通知
- (void)registerNotify
{
    //刷新页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:NOTIFY_CIRCLE_LIST object:nil];
}

- (void)loadAndhandleData
{
    
    NSString * url = [NSString stringWithFormat:@"%@?user_id=%ld", kGetPersonalCircleListPath, [UserService sharedService].user.uid];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            //下拉刷新清空数组
            if (self.isReloading) {
                [self.dataArr removeAllObjects];
                [self.followArray removeAllObjects];
            }
            
            self.isLastPage        = [responseData[HttpResult][@"is_last"] boolValue];
            NSArray * unfollowList = responseData[HttpResult][@"unfollowList"];
            NSArray * followList   = responseData[HttpResult][@"followList"];
            //数据处理 已关注
            for (NSDictionary * circleDic in unfollowList) {
                CircleModel * model          = [[CircleModel alloc] init];
                model.cid                    = [circleDic[@"id"] integerValue];
                model.circle_name            = circleDic[@"circle_name"];
                model.circle_cover_sub_image = circleDic[@"circle_cover_sub_image"];
                model.follow_quantity        = [circleDic[@"follow_quantity"] integerValue];
                [self.dataArr addObject:model];
                
            }
            //数据处理 未关注
            for (NSDictionary * circleDic in followList) {
                CircleModel * model          = [[CircleModel alloc] init];
                model.cid                    = [circleDic[@"id"] integerValue];
                model.circle_name            = circleDic[@"circle_name"];
                model.circle_cover_sub_image = circleDic[@"circle_cover_sub_image"];
                model.follow_quantity        = [circleDic[@"follow_quantity"] integerValue];
                model.isFollow               = YES;
                [self.followArray addObject:model];
            }
            
            [self reloadTable];
            
        }else{
            [self showWarn:responseData[HttpMessage]];
            self.isReloading = NO;
            [self.refreshTableView refreshFinish];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.isReloading = NO;
        [self.refreshTableView refreshFinish];
        [self showWarn:StringCommonNetException];
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
