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
    self.refreshTableView.frame           = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    self.refreshTableView.backgroundColor = [UIColor whiteColor];
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
    if (self.isReloading) {
        return;
    }
    [super refreshData];
    [self loadAndhandleData];
}
//加载更多
- (void)loadingData
{
    if (self.isReloading) {
        return;
    }
    [super loadingData];
    [self loadAndhandleData];
}

- (void)handleTableViewContentWith:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    UserModel * userModel             = self.dataArr[indexPath.row];
    //头像
    CustomImageView * headImageView   = [[CustomImageView alloc] initWithFrame:CGRectMake(10, 7, 57, 57)];
    headImageView.layer.cornerRadius  = 3;
    headImageView.layer.masksToBounds = YES;
    //名字
    CustomLabel * nameLabel           = [[CustomLabel alloc] initWithFrame:CGRectMake(headImageView.right+10, headImageView.y+7, 200, 14)];
    nameLabel.font                    = [UIFont systemFontOfSize:14];
    nameLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];
    
    if (indexPath.row == 0) {
        //圈主标识
        CustomLabel * isManagerLabel       = [[CustomLabel alloc] init];
        isManagerLabel.backgroundColor     = [UIColor colorWithHexString:ColorGold];
        isManagerLabel.frame               = CGRectMake(self.viewWidth-60, 25, 0, 20);
        isManagerLabel.font                = [UIFont systemFontOfSize:12];
        isManagerLabel.text                = KHClubString(@"Circle_Circle_CircleManager");
        isManagerLabel.textAlignment       = NSTextAlignmentCenter;
        isManagerLabel.textColor           = [UIColor colorWithHexString:ColorWhite];
        isManagerLabel.layer.cornerRadius  = 4;
        isManagerLabel.layer.masksToBounds = YES;
        [isManagerLabel sizeToFit];
        isManagerLabel.width += 8;
        isManagerLabel.height = 20;
        [cell.contentView addSubview:isManagerLabel];
    }
    
    //公司
    CustomLabel * jobLabel            = [[CustomLabel alloc] initWithFrame:CGRectMake(headImageView.right+10, nameLabel.bottom+5, 220, 13)];
    jobLabel.font                     = [UIFont systemFontOfSize:13];
    jobLabel.textColor                = [UIColor colorWithHexString:ColorLightBlack];
    //底线
    UIView * lineView                 = [[UIView alloc] initWithFrame:CGRectMake(headImageView.right+10, 64, [DeviceManager getDeviceWidth], 1)];
    lineView.backgroundColor          = [UIColor colorWithHexString:ColorLightGary];
    
    [cell.contentView addSubview:headImageView];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:jobLabel];
    [cell.contentView addSubview:lineView];
    //内容
    [headImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:userModel.head_sub_image]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

#pragma mark- method response

#pragma mark- private method
- (void)loadAndhandleData
{
    
    NSString * url = [NSString stringWithFormat:@"%@?page=%d&circle_id=%ld", kGetCircleMembersPath, self.currentPage, self.circleId];
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
