//
//  PublishCircleNoticeViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "PublishCircleNoticeViewController.h"

@interface PublishCircleNoticeViewController ()

/**
 *  顶部背景视图
 */
@property (strong, nonatomic) UIView              * topBackView;

@property (strong, nonatomic) PlaceHolderTextView * textView;

@end

@implementation PublishCircleNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];
    
    [self initWidget];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout

- (void)initWidget
{
    self.topBackView = [[UIView alloc] init];
    self.textView    = [[PlaceHolderTextView alloc] init];
    
    [self.view  addSubview:self.topBackView];
    [self.view addSubview:self.textView];
}

- (void)configUI {
    
    [self setNavBarTitle:KHClubString(@"News_PublishCircleNotice_Title")];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:KHClubString(@"News_Publish_Send") andBlock:^{
        [sself publishNewClick];
    }];
    [self.navBar.rightBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    [self.navBar.rightBtn setTitleColor:[UIColor colorWithHexString:ColorLightGary] forState:UIControlStateHighlighted];
    
    self.topBackView.backgroundColor = [UIColor whiteColor];
    
    self.textView.frame              = CGRectMake(kCenterOriginX((self.viewWidth-60)), kNavBarAndStatusHeight+30, self.viewWidth-60, 130);
    self.textView.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    self.textView.layer.borderWidth  = 1;
    self.textView.layer.borderColor  = [UIColor colorWithHexString:ColorGold].CGColor;
    [self.textView setPlaceHolder:@""];
    
}

#pragma mark- method response

//发表状态
- (void)publishNewClick
{
    if (self.textView.text.length < 1) {
        [self showHint:KHClubString(@"News_NewsDetail_ContentEmpty")];
        return;
    }
    
    if (self.textView.text.length > 140) {
        [self showHint:KHClubString(@"News_Publish_CotentTooLong")];
        return;
    }
        
    //确定后进行网络上传
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"content_text":self.textView.text,
                              @"circle_id":[NSString stringWithFormat:@"%ld", self.circleID]};

    [self showLoading:nil];
    [HttpService postWithUrlString:kPostNewNoticePath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self showComplete:KHClubString(@"News_Publish_Success")];
            [self hideLoading];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_PUBLISH_NOTICE object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [self showWarn:KHClubString(@"News_Publish_Fail")];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:KHClubString(@"News_Publish_Fail")];
    }];
 
}

#pragma mark- private Method

#pragma mark- override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.textView resignFirstResponder];
}

@end
