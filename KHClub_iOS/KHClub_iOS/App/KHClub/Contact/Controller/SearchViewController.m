//
//  SearchViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/19.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "SearchViewController.h"
#import "OtherPersonalViewController.h"
#import "PublicGroupDetailViewController.h"
#import "SearchContactViewController.h"

@interface SearchViewController ()

//搜索tf
@property (nonatomic, strong) UITextField * searchTextField;
//搜索button
@property (nonatomic, strong) CustomButton * searchBtn;
//通讯录button
@property (nonatomic, strong) CustomButton * contactBtn;

@end

@implementation SearchViewController

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
    self.searchTextField          = [[UITextField alloc] init];
    self.searchTextField.delegate = self;
    self.searchBtn                = [[CustomButton alloc] init];
    self.contactBtn               = [[CustomButton alloc] init];

    [self.view addSubview:self.searchTextField];
    [self.view addSubview:self.searchBtn];
    [self.view addSubview:self.contactBtn];
    
    [self.searchBtn addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configUI
{
    [self setNavBarTitle:NSLocalizedString(@"friend.search", @"Search")];
    
    self.searchTextField.returnKeyType   = UIReturnKeySearch;
    self.searchTextField.textColor       = [UIColor colorWithHexString:ColorDeepBlack];
    self.searchTextField.placeholder     = KHClubString(@"Contact_Search_InputPrompt");
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    self.searchTextField.frame           = CGRectMake(10, kNavBarAndStatusHeight+10, self.viewWidth-85, 35);

    self.searchBtn.frame                 = CGRectMake(self.searchTextField.right + 10, kNavBarAndStatusHeight+10, 60, 35);
    self.searchBtn.titleLabel.font       = [UIFont systemFontOfSize:15];
    self.searchBtn.backgroundColor       = [UIColor colorWithHexString:ColorGold];
    [self.searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.searchBtn setTitle:NSLocalizedString(@"friend.search", @"Search") forState:UIControlStateNormal];
    
    self.contactBtn.frame              = CGRectMake(0, self.searchBtn.bottom+15, self.viewWidth, 60);
    self.contactBtn.backgroundColor    = [UIColor whiteColor];
    
   // 图片
    CustomImageView * contactImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
    contactImageView.image             = [UIImage imageNamed:@"add_contacts_friend_icon"];
    [self.contactBtn addSubview:contactImageView];
    
    CustomLabel * contactLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(60, 10, 200, 40)];
    contactLabel.font          = [UIFont systemFontOfSize:15];
    contactLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    contactLabel.text          = KHClubString(@"Contact_Search_Contacts");
    [self.contactBtn addSubview:contactLabel];
    
}

#pragma mark- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchClick:nil];
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark- event response
- (void)searchClick:(id)sender
{

    if (self.searchTextField.text.length < 1) {
        return;
    }
    
    [self showLoading:nil];

    NSString * path = [NSString stringWithFormat:@"%@?target_id=%@", kFindUserOrGroupPath,  [self.searchTextField.text trim]];
    
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {

        int status = [responseData[@"status"] intValue];
        if (status == HttpStatusCodeSuccess) {
            int direction = [responseData[@"result"][@"type"] intValue];
            //群组
            if (direction == 1) {
                PublicGroupDetailViewController * pgdv = [[PublicGroupDetailViewController alloc] initWithGroupId:[self.searchTextField.text trim]];
                [self pushVC:pgdv];
            }
            //个人
            if (direction == 0) {
                OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
                opvc.uid                           = [responseData[@"result"][@"user_id"] integerValue];
                [self pushVC:opvc];
            }
            [self.searchTextField resignFirstResponder];
            [self hideLoading];
        }else{
            [self showWarn:KHClubString(@"Contact_Search_SearchFail")];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
    
}

- (void)contactClick:(id)sender
{
    SearchContactViewController * scvc = [[SearchContactViewController alloc] init];
    [self pushVC:scvc];
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
