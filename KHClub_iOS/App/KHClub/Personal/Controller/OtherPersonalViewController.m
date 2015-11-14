//
//  OtherPersonalViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/5.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "OtherPersonalViewController.h"
#import "UIImageView+WebCache.h"
#import "PersonalInfoView.h"
#import "ImageModel.h"
#import "MyNewsListViewController.h"

@interface OtherPersonalViewController ()

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
//用户模型
@property (nonatomic, strong) UserModel * otherUser;
//是不是好友
@property (nonatomic, assign) BOOL isFriend;

@end

@implementation OtherPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化
    [self initWidget];
    //编辑UI
    [self configUI];
    
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)configUI
{
    
    //背景滚动视图
    self.backScrollView.frame                        = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight);
    self.backScrollView.showsVerticalScrollIndicator = NO;
    
    //顶部栏设置部分
    CustomButton * imageBackView  = [[CustomButton alloc] initWithFrame:CGRectMake(0, self.infoView.bottom+20, self.viewWidth, 75)];
    imageBackView.backgroundColor = [UIColor whiteColor];

    CustomLabel * imageLabel      = [[CustomLabel alloc] initWithFontSize:18];
    imageLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    imageLabel.frame              = CGRectMake(15, 0, 100, 75);
    imageLabel.text               = KHClubString(@"Personal_Personal_Moments");
    [imageBackView addSubview:imageLabel];
    [imageBackView addTarget:self action:@selector(myImageClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageView1.frame         = CGRectMake(self.viewWidth-70, 10, 55, 55);
    self.imageView2.frame         = CGRectMake(self.imageView1.x-65, 10, 55, 55);
    self.imageView3.frame         = CGRectMake(self.imageView1.x-65, 10, 55, 55);
    [self.backScrollView addSubview:imageBackView];
    [imageBackView addSubview:self.imageView1];
    [imageBackView addSubview:self.imageView2];
    [imageBackView addSubview:self.imageView3];
    
    self.signBackView.frame           = CGRectMake(0, imageBackView.bottom+20, self.viewWidth, 60);
    self.signBackView.backgroundColor = [UIColor colorWithHexString:ColorWhite];
    
    CustomLabel * signTitleLabel      = [[CustomLabel alloc] initWithFontSize:18];
    signTitleLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    signTitleLabel.frame              = CGRectMake(15, 10, 100, 40);
    signTitleLabel.text               = KHClubString(@"Personal_Personal_Sign");
    [self.signBackView addSubview:signTitleLabel];
    
    self.signLabel.frame              = CGRectMake(15, signTitleLabel.bottom, self.viewWidth-30, 0);
    self.signLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    self.signLabel.font               = [UIFont systemFontOfSize:15];
    self.signLabel.numberOfLines      = 0;
    self.signLabel.lineBreakMode      = NSLineBreakByCharWrapping;
    
}

#pragma mark- method response
- (void)myImageClick:(id)sender
{
    MyNewsListViewController * mnlvc = [[MyNewsListViewController alloc] init];
    mnlvc.isOther                    = YES;
    mnlvc.uid                        = self.uid;
    [self pushVC:mnlvc];
}

#pragma mark- private method
//获取用户信息
- (void)getData
{
    //kGetNewsImagesPath
    NSString * path = [kPersnalInformationPath stringByAppendingFormat:@"?uid=%ld&current_id=%ld", self.uid, [UserService sharedService].user.uid];
    debugLog(@"%@", path);
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self handleDataWithDic:responseData];
            
        }else{
            [self showWarn:responseData[HttpMessage]];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

//处理数据
- (void)handleDataWithDic:(NSDictionary *)responseData
{
    //用户信息
    self.otherUser      = [[UserModel alloc] init];
    [self.otherUser setModelWithDic:responseData[HttpResult]];
    
    [self setNavBarTitle:self.otherUser.name];
    
    //签名
    NSString * signStr       = [ToolsManager emptyReturnNone:[UserService sharedService].user.signature];
    CGSize size              = [ToolsManager getSizeWithContent:signStr andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
    self.signLabel.text      = signStr;
    self.signBackView.height = size.height+60;
    self.signLabel.height    = size.height;
    
    if (self.signBackView.bottom < self.backScrollView.height) {
        self.backScrollView.contentSize = CGSizeMake(0, self.backScrollView.height+1);
    }else{
        self.backScrollView.contentSize = CGSizeMake(0, self.signBackView.height+10);
    }
    
    //图片数组
    NSArray * imageList = responseData[HttpResult][@"image_list"];
    
    NSMutableArray * imageModelList = [[NSMutableArray alloc] init];
    //遍历设置图片
    for (int i=0; i<imageList.count; i++) {
        NSDictionary * dic = imageList[i];
        ImageModel * image = [[ImageModel alloc] init];
        image.sub_url      = dic[@"sub_url"];
        image.url          = dic[@"url"];
        [imageModelList addObject:image];
    }
    //图片
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
    
    //设置数据
    [self.infoView setDataWithModel:self.otherUser];
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
