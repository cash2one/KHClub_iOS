//
//  CircleCategoryViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 16/1/5.
//  Copyright © 2016年 JLXC. All rights reserved.
//

#import "CircleCategoryViewController.h"
#import "CategoryView.h"
#import "CircleModel.h"
#import "CircleHomeViewController.h"

@interface CircleCategoryViewController ()

/**
 *  当前选中的类型
 */
@property (nonatomic, assign) CircleType choiceType;
/**
 *  当前选中类型的显示View
 */
@property (nonatomic, strong) CategoryView * choiceCategoryView;

@end

@implementation CircleCategoryViewController
{
    CircleCategoryBlock _block;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWidget];
    [self configUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)initWidget
{
    [self setNavBarTitle:KHClubString(@"Circle_CircleCategory_Title")];
    self.choiceCategoryView        = [[CategoryView alloc] initWithTitle:@"" andTag:0];
    self.choiceCategoryView.hidden = YES;
    //顶部背景
    UIView * topBackView         = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, 45)];
    topBackView.backgroundColor  = [UIColor colorWithHexString:ColorWhite];

    CustomLabel * topTitleLabel  = [[CustomLabel alloc] initWithFontSize:16];
    topTitleLabel.textColor      = [UIColor colorWithHexString:ColorDeepBlack];
    topTitleLabel.frame          = CGRectMake(10, 0, 70, 45);
    topTitleLabel.text           = KHClubString(@"Circle_CircleCategory_Choiced");

    CustomLabel * topPromptLabel = [[CustomLabel alloc] initWithFontSize:12];
    topPromptLabel.textColor     = [UIColor colorWithHexString:@"C8C7CC"];
    topPromptLabel.frame         = CGRectMake(self.viewWidth-150, 0, 140, 45);
    topPromptLabel.text          = KHClubString(@"Circle_CircleCategory_OnlyOne");
    topPromptLabel.textAlignment = NSTextAlignmentRight;

    self.choiceCategoryView.x    = topTitleLabel.right;
    self.choiceCategoryView.y    = 7.5;
    
    
    [self.view addSubview:topBackView];
    [topBackView addSubview:topTitleLabel];
    [topBackView addSubview:self.choiceCategoryView];
    [topBackView addSubview:topPromptLabel];
}

- (void)configUI
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F9F8"];
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:StringCommonFinish andBlock:^{
        [sself choiceOK];
    }];
    //全部类别
    NSArray * categoryArray = @[@(CircleInvestment),@(CircleBusiness),@(CircleTea),@(CircleCigar),@(CircleWealthy),@(CircleArt),
                                @(CircleTour),@(CircleGolf),@(CircleCollege),@(CircleFashion),@(CircleBoat),@(CircleOther)];
    
    NSInteger lineQuantity = 3;
    if (self.viewWidth > 370) {
        lineQuantity = 4;
    }
    
    for (int i=0; i<categoryArray.count; i++) {
        NSNumber * type  = categoryArray[i];
        //构造类别视图 动态布局
        CategoryView * categoryView = [[CategoryView alloc] initWithTitle:[ToolsManager getCircleTypeWith:type.integerValue] andTag:type.integerValue];
        [self.view addSubview:categoryView];
        
        NSInteger columnNum = i%lineQuantity;
        NSInteger lineNum   = i/lineQuantity;
        categoryView.x      = 10+columnNum*92;
        categoryView.y      = kNavBarAndStatusHeight + 65 + lineNum*50;
        
        [categoryView addTarget:self action:@selector(categoryClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
#pragma mark- method response
- (void)categoryClick:(CustomButton *)sender
{
    self.choiceCategoryView.hidden = NO;
    self.choiceType                = sender.tag;
    [self.choiceCategoryView setTitle:sender.currentTitle forState:UIControlStateNormal];
    
}

#pragma mark- private method
/**
 *  选择完成提交
 */
- (void)choiceOK
{
    if (self.choiceType == 0) {
        
        [self showHint:KHClubString(@"Circle_CircleCategory_CategoryNotNull")];
        return;
    }
    
    if (_block) {
        //创建中
        [self showHudInView:self.view hint:KHClubString(@"Circle_CreateCircle_CreateHUD")];
        _block(self.choiceType);
    }
}

- (void)setFinishBlock:(CircleCategoryBlock)block
{
    _block = [block copy];
}

/**
 *  提交成功退出
 */
- (void)postSuccessWithCircleID:(NSInteger)circleID
{
    [self hideHud];
    [self showComplete:KHClubString(@"Circle_CreateCircle_CreateSuccess")];
    //创建成功 进入圈子
    CircleHomeViewController * chvc = [[CircleHomeViewController alloc] init];
    chvc.circleID                   = circleID;
    chvc.isCreate                   = YES;
    [self pushVC:chvc];
}


/**
 *  提示失败
 */
- (void)showFail
{
    [self hideHud];
    [self showWarn:KHClubString(@"Circle_CreateCircle_CreateFail")];
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

