//
//  AddRemarkViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/31.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "AddRemarkViewController.h"
@interface AddRemarkViewController ()

@property (nonatomic, strong) CustomTextField * remarkTextFiled;

@end

@implementation AddRemarkViewController
{
    RemarkBlock _changeBlock;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWidget];
    
    [self configUI];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout
- (void)createWidget
{
    self.remarkTextFiled             = [[CustomTextField alloc] init];
    self.remarkTextFiled.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.remarkTextFiled];
}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"Personal_OtherPersonal_Remark")];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:StringCommonSave andBlock:^{       
        [sself addRemark];
    }];
    
    self.view.backgroundColor      = [UIColor whiteColor];
    
    //备注
    CustomLabel * remarkTitleLabel = [[CustomLabel alloc] initWithFontSize:16];
    remarkTitleLabel.text          = KHClubString(@"Personal_OtherPersonal_RemarkName");
    remarkTitleLabel.frame         = CGRectMake(10, 15+kNavBarAndStatusHeight, 100, 16);
    [self.view addSubview:remarkTitleLabel];
    
    self.remarkTextFiled.frame           = CGRectMake(10, remarkTitleLabel.bottom+15, self.viewWidth-20, 14);
    self.remarkTextFiled.tintColor       = [UIColor colorWithHexString:ColorPlaceHolder];
    self.remarkTextFiled.font            = [UIFont systemFontOfSize:14];
    self.remarkTextFiled.clearButtonMode = UITextFieldViewModeAlways;
    self.remarkTextFiled.placeholder     = KHClubString(@"Personal_OtherPersonal_AddRemark");
    self.remarkTextFiled.backgroundColor = [UIColor clearColor];
    self.remarkTextFiled.borderStyle     = UITextBorderStyleNone;

    UIView * lineView        = [[UIView alloc] initWithFrame:CGRectMake(10, self.remarkTextFiled.bottom+5, self.viewWidth-10, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:ColorLightGary];
    [self.view addSubview:lineView];
    
    //设置备注
    if (self.remark != nil && self.remark.length > 0) {
        self.remarkTextFiled.text = self.remark;
    }
    
}

#pragma mark- private method
- (void)setChangeBlock:(RemarkBlock)block
{
    _changeBlock = [block copy];
}

//增加备注确定
- (void)addRemark
{
    
    NSString * remark = [self.remarkTextFiled.text trim];
    
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"target_id":[NSString stringWithFormat:@"%ld", self.frinedId],
                              @"friend_remark":remark};

    [self showLoading:StringCommonUploadData];

    [HttpService postWithUrlString:kAddRemarkPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        [self hideLoading];
        int status = [responseData[HttpStatus] intValue];
        //成功后
        if (status == HttpStatusCodeSuccess) {
            
            [self showComplete:responseData[HttpMessage]];
            
            if (_changeBlock) {
                _changeBlock(remark);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [self showHint:StringCommonUploadDataFail];
        }

    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideLoading];
        [self showHint:StringCommonNetException];
    }];
}

#pragma mark- override
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.remarkTextFiled resignFirstResponder];
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
