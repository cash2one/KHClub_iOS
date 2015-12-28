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
/**
 *  数据源
 */
@property (nonatomic, strong) NSMutableArray * dataArr;
/**
 *  列表
 */
@property (nonatomic, strong) UITableView    * tableView;
/**
 *  没有选择圈子时的提示
 */
@property (nonatomic, strong) UIView         * noneCircleBackView;
/**
 *  在外面选择的圈子
 */
@property (nonatomic, strong) CircleModel    * choicedCircleModel;

@end

@implementation ChoiceCircleViewController
{
    ChoiceCircleBlock _block;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //配置ui
    [self initWidget];
    [self configUI];
    [self loadAndhandleData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- layout
- (void)initWidget
{
    self.noneCircleBackView = [[UIView alloc] init];
    [self.view addSubview:self.noneCircleBackView];
}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"News_ChoiceCircle_ChoiceTitle")];
    
    self.view.backgroundColor                   = [UIColor colorWithHexString:ColorWhite];
    
    self.tableView                              = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight) style:UITableViewStylePlain];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate                     = self;
    self.tableView.dataSource                   = self;
    self.tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.choiceArray = [[NSMutableArray alloc] init];
    self.dataArr     = [[NSMutableArray alloc] init];
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:StringCommonConfirm andBlock:^{
        [sself choiceOK];
    }];
    
    //无圈子时候的显示
    self.noneCircleBackView.frame    = CGRectMake(0, kNavBarAndStatusHeight+130, self.viewWidth, 86);
    self.noneCircleBackView.hidden   = YES;
    CustomLabel * nonePromptLabel    = [[CustomLabel alloc] initWithFrame:CGRectMake(kCenterOriginX(300), 0, 300, 16)];
    nonePromptLabel.textAlignment    = NSTextAlignmentCenter;
    nonePromptLabel.font             = [UIFont systemFontOfSize:16];
    nonePromptLabel.text             = KHClubString(@"News_ChoiceCircle_ChoiceNone");
    [self.noneCircleBackView addSubview:nonePromptLabel];

    CustomButton * nonePromptBtn     = [[CustomButton alloc] initWithFrame:CGRectMake(20, nonePromptLabel.bottom+30, self.viewWidth-40, 40)];
    nonePromptBtn.titleLabel.font    = [UIFont systemFontOfSize:16];
    [nonePromptBtn setTitle:KHClubString(@"News_ChoiceCircle_ToFollow") forState:UIControlStateNormal];
    nonePromptBtn.layer.cornerRadius = 3;
    nonePromptBtn.backgroundColor    = [UIColor colorWithHexString:ColorGold];
    [self.noneCircleBackView addSubview:nonePromptBtn];
    
    [nonePromptBtn addTarget:self action:@selector(toFollow:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma override

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.choicedCircleModel != nil && indexPath.row == 0) {
        return;
    }
    
    //样式转变
    if ([self.choiceArray containsObject:[NSString stringWithFormat:@"%ld", indexPath.row]]) {
        [self.choiceArray removeObject:[NSString stringWithFormat:@"%ld", indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        [self.choiceArray addObject:[NSString stringWithFormat:@"%ld", indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //关注的
    [cell setContentWithModel:self.dataArr[indexPath.row]];
    
    //样式转变
    if ([self.choiceArray containsObject:[NSString stringWithFormat:@"%ld", indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
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

- (void)toFollow:(id)sender
{
    [self popToTabBarViewController];
}

#pragma mark- private method
- (void)setCircleBlock:(ChoiceCircleBlock)block
{
    _block = [block copy];
}

- (void)loadAndhandleData
{
    [self showLoading:StringCommonDownloadData];
    NSString * url = [NSString stringWithFormat:@"%@?user_id=%ld", kGetMyFollowCircleListPath, [UserService sharedService].user.uid];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        [self hideLoading];
        if (status == HttpStatusCodeSuccess) {
            
            NSArray * list  = responseData[HttpResult][HttpList];
            //数据处理
            for (NSDictionary * circleDic in list) {
                CircleModel * model          = [[CircleModel alloc] init];
                model.cid                    = [circleDic[@"id"] integerValue];
                model.follow_quantity        = [circleDic[@"follow_quantity"] integerValue];                
                model.circle_name            = circleDic[@"circle_name"];
                model.circle_cover_sub_image = circleDic[@"circle_cover_sub_image"];
                model.isFollow               = YES;
                [self.dataArr addObject:model];
                //选中的那个
                if (self.circleID != 0 && self.circleID == model.cid) {
                    self.choicedCircleModel = model;
                }
            }
            //存在
            if (self.choicedCircleModel) {
                [self.dataArr removeObject:self.choicedCircleModel];
                [self.dataArr insertObject:self.choicedCircleModel atIndex:0];
                //默认选中
                [self.choiceArray addObject:@"0"];
            }
            
            if (self.dataArr.count > 0) {
                self.noneCircleBackView.hidden = YES;
                self.tableView.hidden          = NO;
            }else{
                self.noneCircleBackView.hidden = NO;
                self.tableView.hidden          = YES;
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

- (void)popTo:(UIViewController *)vc
{
    [self.navigationController popToViewController:vc animated:YES];
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
