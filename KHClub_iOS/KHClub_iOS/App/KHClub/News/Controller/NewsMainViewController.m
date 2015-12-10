//
//  NewsMainViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/6/10.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "NewsMainViewController.h"
#import "PublishNewsViewController.h"
#import "NotifyNewsViewController.h"
#import "NewsListViewController.h"
#import "CircleListViewController.h"
#import "CreateCircleViewController.h"

@interface NewsMainViewController ()

/**
 *  左上角未读红点
 */
@property (nonatomic, strong) UIView                   * unreadView;
/**
 *  状态列表
 */
@property (nonatomic, strong) NewsListViewController   * newsListVC;
/**
 *  圈子列表
 */
@property (nonatomic, strong) CircleListViewController * circleListVC;
/**
 *  背景滚动视图
 */
@property (nonatomic, strong) UIScrollView             * backScroll;
/**
 *  新闻列表
 */
@property (nonatomic, strong) CustomButton             * newsListBtn;
/**
 *  圈子列表
 */
@property (nonatomic, strong) CustomButton             * circleListBtn;

@end

@implementation NewsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化控件
    [self initWidget];
    //初始化UI
    [self configUI];
    //初始化ChildVC
    [self initChildVC];
    //设置通知
    [self registerNotify];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark- layout

- (void)initWidget
{
    self.newsListBtn   = [[CustomButton alloc] init];
    self.circleListBtn = [[CustomButton alloc] init];
    self.backScroll    = [[UIScrollView alloc] init];
    self.unreadView    = [[UIView alloc] init];
    
    [self.view addSubview:self.backScroll];
    [self.navBar addSubview:self.unreadView];
    [self.navBar addSubview:self.newsListBtn];
    [self.navBar addSubview:self.circleListBtn];
    
    [self.newsListBtn addTarget:self action:@selector(newsListClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.circleListBtn addTarget:self action:@selector(circleListClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configUI
{
    
    __weak typeof(self) sself = self;
    //左上角通知
    [self.navBar setLeftBtnWithContent:@"" andBlock:^{
        NotifyNewsViewController * nnvc = [[NotifyNewsViewController alloc] init];
        [sself pushVC:nnvc];
    }];
    //右上角发布
    [self.navBar setRightBtnWithContent:@"" andBlock:^{
        
        //发布
        if (self.backScroll.contentOffset.x >= self.viewWidth) {
            PublishNewsViewController * pnvc = [[PublishNewsViewController alloc] init];
            [sself pushVC:pnvc];
        }else{
            //创建
            CreateCircleViewController * ccvc = [[CreateCircleViewController alloc] init];
            [sself presentViewController:ccvc animated:YES completion:nil];
        }
        
    }];
    
    self.navBar.leftBtn.hidden                 = NO;
    self.navBar.leftBtn.imageEdgeInsets        = UIEdgeInsetsMake(2, 6, 0, 16);
    self.navBar.leftBtn.imageView.contentMode  = UIViewContentModeScaleAspectFit;
    self.navBar.rightBtn.imageEdgeInsets       = UIEdgeInsetsMake(12, 26, 12, 0);
    self.navBar.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.navBar.leftBtn setImage:[UIImage imageNamed:@"news_notice_normal"] forState:UIControlStateNormal];
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"news_publish_normal"] forState:UIControlStateNormal];
    
    //未读
    self.unreadView.frame              = CGRectMake(30, 29, 6, 6);
    self.unreadView.layer.cornerRadius = 3;
    self.unreadView.backgroundColor    = [UIColor redColor];

    //背景scroll
    self.backScroll.frame                          = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kTabBarHeight);
    self.backScroll.pagingEnabled                  = YES;
    self.backScroll.contentSize                    = CGSizeMake(self.viewWidth*2, 0);
    self.backScroll.showsHorizontalScrollIndicator = NO;
    self.backScroll.delegate                       = self;
    self.backScroll.bounces                        = NO;
    
    //顶部两个滑块按钮
    self.newsListBtn.frame                        = CGRectMake(self.viewWidth/2+5, 33, 80, 20);
    self.newsListBtn.titleLabel.font            = [UIFont systemFontOfSize:14];
    self.newsListBtn.contentHorizontalAlignment   = UIControlContentHorizontalAlignmentCenter;

    self.circleListBtn.frame                      = CGRectMake(self.viewWidth/2-85, 33, 80, 20);
    self.circleListBtn.titleLabel.font              = [UIFont systemFontOfSize:16];
    self.circleListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self.circleListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.newsListBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];
    [self.newsListBtn setTitle:KHClubString(@"News_NewsList_MomentsTitle") forState:UIControlStateNormal];
    [self.circleListBtn setTitle:KHClubString(@"News_CircleList_CircleTitle") forState:UIControlStateNormal];
}


//添加子类VC
- (void)initChildVC
{
    //新闻VC
    self.newsListVC            = [[NewsListViewController alloc] init];
    self.newsListVC.view.frame = CGRectMake(self.viewWidth, 0, self.viewWidth, self.backScroll.height);
    [self addChildViewController:self.newsListVC];
    [self.backScroll addSubview:self.newsListVC.view];
    
    //圈子VC
    self.circleListVC            = [[CircleListViewController alloc] init];
    self.circleListVC.view.frame = CGRectMake(0, 0, self.viewWidth, self.backScroll.height);
    [self addChildViewController:self.circleListVC];
    [self.backScroll addSubview:self.circleListVC.view];
    
}

#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= self.viewWidth) {
        [self selectBarIndex:2];
    }else{
        [self selectBarIndex:1];
    }
}


#pragma mark- method response
- (void)newsListClick:(id)sender
{
    if (self.backScroll.contentOffset.x < self.viewWidth) {
        [self selectBarIndex:2];
        [UIView animateWithDuration:0.2 animations:^{
            self.backScroll.contentOffset = CGPointMake(self.viewWidth, 0);
        }];
    }
}

- (void)circleListClick:(id)sender
{
    if (self.backScroll.contentOffset.x >= self.viewWidth) {
        [self selectBarIndex:1];
        [UIView animateWithDuration:0.2 animations:^{
            self.backScroll.contentOffset = CGPointZero;
        }];
    }
}

#pragma mark- private method
- (void)registerNotify
{
    //新推送到来
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotify:) name:NOTIFY_NEWS_PUSH object:nil];
    [self refreshNotify:nil];    

}

- (void)refreshNotify:(id)sender
{
    
    //徽标 最多显示99
    //未读推送
    NSInteger newsUnreadCount = [NewsPushModel findUnreadCount].count;
    if (newsUnreadCount > 0) {
        self.unreadView.hidden = NO;
    }else{
        self.unreadView.hidden = YES;
    }
    
}

//顶部更换 字体颜色更换
- (void)selectBarIndex:(NSInteger)index
{
    if (index == 1) {
        self.newsListBtn.titleLabel.font   = [UIFont systemFontOfSize:14];
        self.circleListBtn.titleLabel.font = [UIFont systemFontOfSize:16];

        [self.newsListBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];
        [self.circleListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        self.newsListBtn.titleLabel.font   = [UIFont systemFontOfSize:16];
        self.circleListBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [self.newsListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.circleListBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];
    }
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
