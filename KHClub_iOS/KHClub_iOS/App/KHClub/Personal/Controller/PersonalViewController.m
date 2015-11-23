//
//  PersonalViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/20.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "PersonalViewController.h"
#import "MyNewsListViewController.h"
#import "ImageModel.h"
#import "PersonalInfoView.h"
#import "UIImageView+WebCache.h"
#import "PersonalSettingViewController.h"

@interface PersonalViewController ()

//背景滚动视图
@property (nonatomic, strong) UIScrollView * backScrollView;

//横版滚动视图
@property (nonatomic, strong) PersonalInfoView * infoView;

@property (nonatomic, strong) CustomImageView * imageView1;
@property (nonatomic, strong) CustomImageView * imageView2;
@property (nonatomic, strong) CustomImageView * imageView3;

//签名背景
@property (nonatomic, strong) UIView * signBackView;
//签名
@property (nonatomic, strong) CustomLabel * signLabel;

@end

@implementation PersonalViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化
    [self initWidget];
    //编辑UI
    [self configUI];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshUI];
}

#pragma mark- layout

- (void)initWidget
{
    //背景滚动视图
    self.backScrollView    = [[UIScrollView alloc] init];
    self.infoView          = [[PersonalInfoView alloc] initWithFrame:CGRectMake(10, 10, self.viewWidth-20, 190) isSelf:YES];
    self.imageView1        = [[CustomImageView alloc] init];
    self.imageView2        = [[CustomImageView alloc] init];
    self.imageView3        = [[CustomImageView alloc] init];
    
    //签名部分
    self.signBackView      = [[UIView alloc] init];
    self.signLabel         = [[CustomLabel alloc] init];
    
    [self.view addSubview:self.backScrollView];
    [self.backScrollView addSubview:self.infoView];
    [self.backScrollView addSubview:self.signBackView];
    [self.signBackView addSubview:self.signLabel];
 
    __weak typeof(self) sself = self;
    //左上角设置
    [self.navBar setLeftBtnWithContent:@"" andBlock:^{
        PersonalSettingViewController * psVC= [[PersonalSettingViewController alloc] init];
        [sself pushVC:psVC];
    }];
    //右上角名片
    [self.navBar setRightBtnWithContent:@"" andBlock:^{

    }];
}

- (void)configUI
{
 
    [self setNavBarTitle:KHClubString(@"Personal_Personal_Title")];
    
    //背景滚动视图
    self.backScrollView.frame                        = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kTabBarHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;

    //顶部栏设置部分
    self.navBar.leftBtn.hidden                       = NO;
    self.navBar.leftBtn.imageEdgeInsets              = UIEdgeInsetsMake(6, 0, 0, 16);
    self.navBar.leftBtn.imageView.contentMode        = UIViewContentModeScaleAspectFit;
    self.navBar.rightBtn.imageEdgeInsets             = UIEdgeInsetsMake(12, 26, 12, 0);
    self.navBar.rightBtn.imageView.contentMode       = UIViewContentModeScaleAspectFit;
    [self.navBar.leftBtn setImage:nil forState:UIControlStateNormal];
    //名片和设置
    [self.navBar.leftBtn setImage:[UIImage imageNamed:@"personal_setting"] forState:UIControlStateNormal];
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"personal_more"] forState:UIControlStateNormal];

    CustomButton * imageBackView  = [[CustomButton alloc] initWithFrame:CGRectMake(0, self.infoView.bottom+10, self.viewWidth, 60)];
    imageBackView.backgroundColor = [UIColor whiteColor];

    CustomLabel * imageLabel      = [[CustomLabel alloc] initWithFontSize:17];
    imageLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    imageLabel.frame              = CGRectMake(15, 0, 80, 60);
    imageLabel.text               = KHClubString(@"Personal_Personal_Moments");
    [imageBackView addSubview:imageLabel];

    self.imageView1.frame         = CGRectMake(imageLabel.right+5, 5, 50, 50);
    self.imageView2.frame         = CGRectMake(self.imageView1.right+5, 5, 50, 50);
    self.imageView3.frame         = CGRectMake(self.imageView2.right+5, 5, 50, 50);
    [self.backScrollView addSubview:imageBackView];
    [imageBackView addSubview:self.imageView1];
    [imageBackView addSubview:self.imageView2];
    [imageBackView addSubview:self.imageView3];
    [imageBackView addTarget:self action:@selector(myImageClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.signBackView.frame           = CGRectMake(0, imageBackView.bottom+1, self.viewWidth, 60);
    self.signBackView.backgroundColor = [UIColor colorWithHexString:ColorWhite];

    CustomLabel * signTitleLabel      = [[CustomLabel alloc] initWithFontSize:17];
    signTitleLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    signTitleLabel.frame              = CGRectMake(15, 0, 100, 40);
    signTitleLabel.text               = KHClubString(@"Personal_Personal_Sign");
    [self.signBackView addSubview:signTitleLabel];

    self.signLabel.frame              = CGRectMake(15, signTitleLabel.bottom, self.viewWidth-30, 0);
    self.signLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    self.signLabel.font               = [UIFont systemFontOfSize:15];
    self.signLabel.numberOfLines      = 0;
    self.signLabel.lineBreakMode      = NSLineBreakByCharWrapping;
    
}

- (void)refreshUI
{
    [self.infoView setSelfData];
    //状态更新
    [self getNewsImages];
    //签名
    NSString * signStr       = [ToolsManager emptyReturnNone:[UserService sharedService].user.signature];
    CGSize size              = [ToolsManager getSizeWithContent:signStr andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
    self.signLabel.text      = signStr;
    self.signBackView.height = size.height+50;
    self.signLabel.height    = size.height;

    if (self.signBackView.bottom < self.backScrollView.height) {
        self.backScrollView.contentSize = CGSizeMake(0, self.backScrollView.height+1);
    }else{
        self.backScrollView.contentSize = CGSizeMake(0, self.signBackView.height+10);
    }
    
}

#pragma mark- method response
- (void)myImageClick:(id)sender
{
    MyNewsListViewController * mnlvc = [[MyNewsListViewController alloc] init];
    [self pushVC:mnlvc];
}

#pragma mark- private method
//获取十张最新状态的图片
- (void)getNewsImages
{
    //kGetNewsImagesPath
    NSString * path = [kGetNewsCoverListPath stringByAppendingFormat:@"?uid=%ld", [UserService sharedService].user.uid];
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            NSArray * imageList = responseData[HttpResult][HttpList];
            
            NSMutableArray * imageModelList = [[NSMutableArray alloc] init];
            //遍历设置图片
            for (int i=0; i<imageList.count; i++) {
                NSDictionary * dic = imageList[i];
                ImageModel * image = [[ImageModel alloc] init];
                image.sub_url      = dic[@"sub_url"];
                image.url          = dic[@"url"];
                [imageModelList addObject:image];
            }
            self.imageView1.hidden = YES;
            self.imageView2.hidden = YES;
            self.imageView3.hidden = YES;
            NSArray * imageArr = @[self.imageView1, self.imageView2, self.imageView3];
            for (int i=0; i<imageModelList.count; i++) {
                ImageModel * image      = imageModelList[i];
                UIImageView * imageView = imageArr[i];
                imageView.hidden        = NO;
                [imageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:image.sub_url]] placeholderImage:[UIImage imageNamed:@"loading_default"]];
            }

        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark- override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
