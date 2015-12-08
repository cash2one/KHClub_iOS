//
//  CircleMembersViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/8.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleMembersViewController.h"
#import "OtherPersonalViewController.h"
#import "UserModel.h"
#import "UIImageView+WebCache.h"

@interface CircleMembersViewController ()

@end

@implementation CircleMembersViewController

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
    [self setNavBarTitle:KHClubString(@"News_CircleList_CircleMember")];
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

- (void)handleTableViewContentWith:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    UserModel * userModel             = self.dataArr[indexPath.row];
    //头像
    CustomImageView * headImageView   = [[CustomImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
    headImageView.layer.cornerRadius  = 2;
    headImageView.layer.masksToBounds = YES;
    //名字
    CustomLabel * nameLabel           = [[CustomLabel alloc] initWithFrame:CGRectMake(headImageView.right+10, headImageView.y+3, 0, 20)];
    nameLabel.font                    = [UIFont systemFontOfSize:FontListName];
    nameLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];
    //公司
    CustomLabel * jobLabel            = [[CustomLabel alloc] initWithFrame:CGRectMake(headImageView.right+10, nameLabel.bottom+1, 220, 20)];
    jobLabel.font                     = [UIFont systemFontOfSize:13];
    jobLabel.textColor                = [UIColor colorWithHexString:ColorLightBlack];
    //底线
    UIView * lineView                 = [[UIView alloc] initWithFrame:CGRectMake(10, 64, [DeviceManager getDeviceWidth], 1)];
    lineView.backgroundColor          = [UIColor colorWithHexString:ColorLightGary];
    
    [cell.contentView addSubview:headImageView];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:jobLabel];
    [cell.contentView addSubview:lineView];
    
    //内容
    [headImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:userModel.head_image]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    nameLabel.text = [ToolsManager emptyReturnNone:userModel.name];
    jobLabel.text  = [ToolsManager emptyReturnNone:userModel.job];
    
}

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    UserModel * model                  = self.dataArr[indexPath.row];
    opvc.uid                           = model.uid;
    [self pushVC:opvc];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

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
                UserModel * model    = [[UserModel alloc] init];
                model.uid            = [cardDic[@"user_id"] integerValue];
                model.name           = cardDic[@"name"];
                model.head_sub_image = cardDic[@"head_sub_image"];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
