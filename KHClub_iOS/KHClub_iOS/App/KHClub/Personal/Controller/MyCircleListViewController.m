//
//  MyCircleListViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/9.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "MyCircleListViewController.h"
#import "CircleHomeViewController.h"
#import "CircleModel.h"
#import "CircleCell.h"

@interface MyCircleListViewController ()

@end

@implementation MyCircleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //处理继承table
    self.refreshTableView.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    [self refreshData];
    self.refreshTableView.footLabel.hidden             = YES;
    self.refreshTableView.showsVerticalScrollIndicator = NO;
    
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
    CircleModel * circle            = self.dataArr[indexPath.row];
    //圈子ID
    cdvc.circleId                   = circle.cid;
    [self pushVC:cdvc];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

#pragma mark- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellid = @"circleList";
    CircleCell * cell = [self.refreshTableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell          = [[CircleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    //关注的
    [cell setContentWithModel:self.dataArr[indexPath.row]];
    
    return cell;
}

#pragma mark- method response

#pragma mark- private method
- (void)loadAndhandleData
{
    
    NSString * url = [NSString stringWithFormat:@"%@?page=%d&user_id=%ld", kGetCircleListPath, self.currentPage, [UserService sharedService].user.uid];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            //下拉刷新清空数组
            if (self.isReloading) {
                [self.dataArr removeAllObjects];
            }
            
            self.isLastPage = [responseData[HttpResult][@"is_last"] boolValue];
            NSArray * list  = responseData[HttpResult][HttpList];
            //数据处理
            for (NSDictionary * circleDic in list) {
                CircleModel * model      = [[CircleModel alloc] init];
                model.cid                = [circleDic[@"id"] integerValue];
                model.circle_name        = circleDic[@"title"];
                model.circle_detail      = circleDic[@"intro"];
                model.circle_cover_image = circleDic[@"image"];
                model.manager_name       = circleDic[@"manager_name"];
                model.phone_num          = circleDic[@"phone_num"];
                model.web                = circleDic[@"web"];
                model.wx_num             = circleDic[@"wx_num"];
                model.address            = circleDic[@"address"];
                [self.dataArr addObject:model];
                
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
