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

@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation MyCircleListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //配置ui
    [self configUI];
    [self loadAndhandleData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- layout
- (void)configUI
{
    self.tableView                              = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight) style:UITableViewStylePlain];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate                     = self;
    self.tableView.dataSource                   = self;
    self.tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.dataArr     = [[NSMutableArray alloc] init];

    if (self.userId) {
        [self setNavBarTitle:KHClubString(@"Personal_Personal_HisCircle")];
    }else{
        [self setNavBarTitle:KHClubString(@"Personal_Personal_MyCircle")];
    }
    if (self.newsId != 0) {
        [self setNavBarTitle:KHClubString(@"Personal_Personal_CircleList")];
    }
}

#pragma override

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CircleModel * circle            = self.dataArr[indexPath.row];
    //点击
    CircleHomeViewController * chvc = [[CircleHomeViewController alloc] init];
    chvc.circleID                   = circle.cid;
    [self pushVC:chvc];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

#pragma mark- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellid = @"circleList";
    CircleCell * cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
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
    
    NSString * url = [NSString stringWithFormat:@"%@?user_id=%ld", kGetMyCircleListPath, [UserService sharedService].user.uid];
    if (self.userId != 0) {
        url = [NSString stringWithFormat:@"%@?user_id=%ld", kGetMyCircleListPath, self.userId];
    }
    
    if (self.newsId != 0) {
        //获取动态所属圈子接口
        url = [NSString stringWithFormat:@"%@?news_id=%ld", kNewsCircleListPath, self.newsId];
    }
    
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {

            NSArray * list  = responseData[HttpResult];
            //数据处理
            for (NSDictionary * circleDic in list) {
                CircleModel * model          = [[CircleModel alloc] init];
                model.cid                    = [circleDic[@"id"] integerValue];
                model.follow_quantity        = [circleDic[@"follow_quantity"] integerValue];
                model.circle_name            = circleDic[@"circle_name"];
                model.circle_cover_sub_image = circleDic[@"circle_cover_sub_image"];
                model.isFollow               = YES;
                [self.dataArr addObject:model];
            }

            [self.tableView reloadData];

        }else{

        }

    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
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
