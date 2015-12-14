//
//  ChoiceCircleViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/11.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "ChoiceCircleViewController.h"
#import "CircleHomeViewController.h"
#import "CircleModel.h"
#import "CircleCell.h"

@interface ChoiceCircleViewController ()

/**
 *  选择的数组
 */
@property (nonatomic, strong) NSMutableArray * choiceArray;

@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation ChoiceCircleViewController
{
    ChoiceCircleBlock _block;
}

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
    [self.view addSubview:self.tableView];
    
    self.choiceArray = [[NSMutableArray alloc] init];
    self.dataArr     = [[NSMutableArray alloc] init];
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:StringCommonConfirm andBlock:^{
        [sself choiceOK];
    }];
    
//    [self.navBar setLeftBtnWithContent:@"" andBlock:^{
//        [sself dismissViewControllerAnimated:YES completion:nil];
//    }];
}

#pragma override

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //样式转变
    if ([self.choiceArray containsObject:[NSString stringWithFormat:@"%ld", indexPath.row]]) {
        [self.choiceArray removeObject:[NSString stringWithFormat:@"%ld", indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        [self.choiceArray addObject:[NSString stringWithFormat:@"%ld", indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
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
    CircleCell * cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell          = [[CircleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    //关注的
    [cell setContentWithModel:self.dataArr[indexPath.row]];
    
    return cell;
}

#pragma mark- method response
- (void)choiceOK
{
    if (self.choiceArray.count < 1) {
        [self showHint:KHClubString(@"News_ChoiceCircle_ChoiceNone")];
        return;
    }
    
    //数据处理
    NSMutableArray * tmpCircles = [[NSMutableArray alloc] init];
    for (NSString * location in self.choiceArray) {
        CircleModel * circle = self.dataArr[location.integerValue];
        [tmpCircles addObject:[NSString stringWithFormat:@"%ld", circle.cid]];
    }
    
    if (_block) {
        _block(tmpCircles);
    }
}

#pragma mark- private method
- (void)setCircleBlock:(ChoiceCircleBlock)block
{
    _block = [block copy];
}

- (void)loadAndhandleData
{
    
    NSString * url = [NSString stringWithFormat:@"%@?user_id=%ld", kGetMyFollowCircleListPath, [UserService sharedService].user.uid];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            NSArray * list  = responseData[HttpResult][HttpList];
            //数据处理
            for (NSDictionary * circleDic in list) {
                CircleModel * model          = [[CircleModel alloc] init];
                model.cid                    = [circleDic[@"id"] integerValue];
                model.circle_name            = circleDic[@"circle_name"];
                model.circle_cover_sub_image = circleDic[@"circle_cover_sub_image"];
                model.isFollow               = YES;
                [self.dataArr addObject:model];
            }
            
            [self.tableView reloadData];
            
        }else{
            [self showWarn:responseData[HttpMessage]];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
    
}

/**
 *  提交成功退出
 */
- (void)popToTab
{
    [self popToTabBarViewController];
    [self showComplete:KHClubString(@"News_Publish_Success")];
}

/**
 *  提示失败
 */
- (void)showFail
{
    [self showWarn:KHClubString(@"News_Publish_Fail")];
}

/**
 *  提示异常
 */

- (void)showException
{
    [self showWarn:StringCommonNetException];
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
