//
//  CardListViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/23.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CardListViewController.h"
#import "OtherPersonalViewController.h"
#import "CardModel.h"
#import "CardCell.h"

@interface CardListViewController ()

@end

@implementation CardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    self.refreshTableView.frame = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshData];
}

#pragma mark- layout
- (void)configUI
{
    [self setNavBarTitle:NSLocalizedString(@"title.cardlist",@"Card")];
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
    [super loadingData];
    [self loadAndhandleData];
}

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    CardModel * model                  = self.dataArr[indexPath.row];
    opvc.uid                           = model.uid;
    [self pushVC:opvc];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KHClubString(@"Common_Delete");
}

#pragma mark- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellid = [NSString stringWithFormat:@"%@%ld", @"cardList", indexPath.row];
    CardCell * cell   = [self.refreshTableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    [cell setContentWithModel:self.dataArr[indexPath.row]];
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self deleteCardModel:self.dataArr[indexPath.row]];
//}

#pragma mark- method response

#pragma mark- private method
- (void)loadAndhandleData
{
    
    NSString * url = [NSString stringWithFormat:@"%@?page=%d&user_id=%ld", kGetCardListPath, self.currentPage, [UserService sharedService].user.uid];
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
            for (NSDictionary * cardDic in list) {
                if ([cardDic[@"is_friend"] boolValue]) {
                    continue;
                }
                CardModel * model    = [[CardModel alloc] init];
                model.uid            = [cardDic[@"user_id"] integerValue];
                model.name           = cardDic[@"name"];
                model.head_sub_image = cardDic[@"head_sub_image"];
                model.company_name   = cardDic[@"company_name"];
                model.job            = cardDic[@"job"];
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

- (void)deleteCardModel:(CardModel *)model
{
//    NSDictionary * params = @{@"uid":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
//                              @"current_id":[NSString stringWithFormat:@"%ld", model.uid]};
//    
//    debugLog(@"%@ %@", kDeleteVisitPath, params);
//    [self showLoading:@"删除中"];
//    [HttpService postWithUrlString:kDeleteVisitPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
//        debugLog(@"%@", responseData);
//        int status = [responseData[HttpStatus] intValue];
//        if (status == HttpStatusCodeSuccess) {
//            
//            [self showComplete:responseData[HttpMessage]];
//            [self.dataArr removeObject:model];
//            [self.refreshTableView reloadData];
//            
//        }else{
//            [self.dataArr removeObject:model];
//            [self showWarn:responseData[HttpMessage]];
//            [self.refreshTableView reloadData];
//        }
//        
//    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self showWarn:StringCommonNetException];
//    }];
    
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
