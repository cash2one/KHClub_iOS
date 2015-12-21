/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "ContactsViewController.h"
#import "UIImageView+WebCache.h"
#import "QRcodeViewController.h"
#import "QRcodeCardView.h"
#import "InvitationManager.h"
#import "BaseTableViewCell.h"
#import "RealtimeSearchUtil.h"
#import "ChineseToPinyin.h"
#import "EMSearchDisplayController.h"
#import "OtherPersonalViewController.h"
#import "AddFriendViewController.h"
#import "ApplyViewController.h"
#import "GroupListViewController.h"
#import "ChatViewController.h"
#import "RobotListViewController.h"
#import "SearchViewController.h"
#import "CreateGroupViewController.h"
#import "CardListViewController.h"
#import "IMUtils.h"

//@implementation EMBuddy (search)
//
////根据用户昵称进行搜索
//- (NSString*)showName
//{
////    return [[UserProfileManager sharedInstance] getNickNameWithUsername:self.username];
//    return [[IMUtils shareInstance] getNickName:self.username];
//}
//
//@end

@interface ContactsViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, BaseTableCellDelegate, IChatManagerDelegate>
{
    NSIndexPath *_currentLongPressIndex;
}

@property (strong, nonatomic) NSMutableArray *contactsSource;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *sectionTitles;

@property (strong, nonatomic) UILabel *unapplyCountLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) GroupListViewController *groupController;
//弹出视图背景
@property (nonatomic, strong) UIView * popBackView;
//屏幕遮罩
@property (nonatomic, strong) UIView * screenCoverView;

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        _contactsSource = [NSMutableArray array];
        _sectionTitles = [NSMutableArray array];
        [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.frame = CGRectMake(0, kNavBarAndStatusHeight, self.view.frame.size.width, self.view.frame.size.height - kNavBarAndStatusHeight-kTabBarHeight);
    [self.view addSubview:self.tableView];
    
    [self setNavBarTitle:KHClubString(@"Common_Main_Contact")];
    
    [self initUI];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadApplyView];
    [self reloadDataSource];
}

- (void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark- layout
- (void)initUI
{
    //定制部分
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:@"" andBlock:^{
        [sself showRightPopView];
    }];
    
    [self.navBar.rightBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.navBar.rightBtn.imageEdgeInsets       = UIEdgeInsetsMake(12, 26, 12, 0);
    self.navBar.rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.screenCoverView                       = [[UIView alloc] init];
    self.popBackView                           = [[UIView alloc] init];
    [self.view addSubview:self.screenCoverView];
    [self.view addSubview:self.popBackView];
    //遮罩点击消失
    UITapGestureRecognizer * dissmissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCover:)];
    [self.screenCoverView addGestureRecognizer:dissmissTap];
    
    //右上角PopView
    self.popBackView.backgroundColor     = [UIColor colorWithHexString:@"4d4d4d"];
    self.popBackView.layer.masksToBounds = YES;
    self.screenCoverView.frame           = self.view.bounds;
    self.screenCoverView.hidden          = YES;
    
    //扫描二维码
    CustomButton * qrcodeBtn    = [[CustomButton alloc] initWithFrame:CGRectMake(10, 0, 120, 45)];
    //添加好友
    CustomButton * addFriendBtn = [[CustomButton alloc] initWithFrame:CGRectMake(10, 45, 120, 45)];
    //新建群聊
    CustomButton * newGroupBtn  = [[CustomButton alloc] initWithFrame:CGRectMake(10, 90, 120, 45)];
    //我的二维码
    CustomButton * myQrcodeBtn  = [[CustomButton alloc] initWithFrame:CGRectMake(10, 135, 120, 45)];
    
    [self defaultTopRightBtnHandle:qrcodeBtn imageName:@"icon_menu_qr_scan" andTitle:KHClubString(@"Message_Message_ScanQrcode")];
    [self defaultTopRightBtnHandle:addFriendBtn imageName:@"icon_menu_add_friend" andTitle:KHClubString(@"Message_Message_Add")];
    [self defaultTopRightBtnHandle:newGroupBtn imageName:@"icon_menu_new_group" andTitle:KHClubString(@"Message_Message_Group")];
    [self defaultTopRightBtnHandle:myQrcodeBtn imageName:@"icon_menu_my_qr_code" andTitle:KHClubString(@"Message_Message_MyQrcode")];
    
    qrcodeBtn.tag    = 1;
    addFriendBtn.tag = 2;
    newGroupBtn.tag  = 3;
    myQrcodeBtn.tag  = 4;
}
//默认
- (void)defaultTopRightBtnHandle:(CustomButton *)btn imageName:(NSString *)imageName andTitle:(NSString *)title
{
    CustomImageView * leftImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 13, 20, 20)];
    leftImageView.contentMode       = UIViewContentModeScaleAspectFit;
    leftImageView.image             = [UIImage imageNamed:imageName];
    [btn addSubview:leftImageView];
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentEdgeInsets          = UIEdgeInsetsMake(0, 25, 0, 0);
    btn.titleLabel.font            = [UIFont systemFontOfSize:13];
    [btn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:ColorLightWhite] forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    [self.popBackView addSubview:btn];
    [btn addTarget:self action:@selector(popViewClick:) forControlEvents:UIControlEventTouchUpInside];
}

//显示右边弹窗
- (void)showRightPopView
{
    self.screenCoverView.hidden = NO;
    self.popBackView.frame      = CGRectMake(self.viewWidth-35, kNavBarAndStatusHeight, 0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.popBackView.frame                   = CGRectMake(self.viewWidth-120, kNavBarAndStatusHeight, 120, 180);
//        self.navBar.rightBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
    }];
}

//遮罩点击消失
- (void)dismissCover:(UITapGestureRecognizer *)ges
{
    self.screenCoverView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.popBackView.frame                   = CGRectMake(self.viewWidth-35, 57, 0, 0);
//        self.navBar.rightBtn.imageView.transform = CGAffineTransformIdentity;
    }];
}
//点击
- (void)popViewClick:(CustomButton *)sender
{
    switch (sender.tag) {
        case 1:
        {
            QRcodeViewController * qvc = [[QRcodeViewController alloc] init];
            qvc.lastViewController     = self;
            [self presentViewController:qvc animated:YES completion:nil];
        }
            break;
        case 2:
        {
            SearchViewController * svc = [[SearchViewController alloc] init];
            [self pushVC:svc];
        }
            break;
        case 3:
        {
            CreateGroupViewController * cgvc = [[CreateGroupViewController alloc] init];
            [self pushVC:cgvc];
        }
            break;
        case 4:
        {
            QRcodeCardView * qcv = [[QRcodeCardView alloc] init];
            [self getQRCodeWithImageView:qcv.imageView];
            [qcv show];
        }
            break;
        default:
            break;
    }
    
    [self dismissCover:nil];
}

//二维码
- (void)getQRCodeWithImageView:(UIImageView *)imageView
{
    
    NSString * path = [kGetUserQRCodePath stringByAppendingFormat:@"?user_id=%ld", [UserService sharedService].user.uid];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kRootAddr,[UserService sharedService].user.qr_code]]];
    [HttpService getWithUrlString:path andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            NSString *path = [NSString stringWithFormat:@"%@%@",kRootAddr,responseData[HttpResult]];
            [imageView sd_setImageWithURL:[NSURL URLWithString:path]];
        }
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

#pragma mark - getter

- (UILabel *)unapplyCountLabel
{
    if (_unapplyCountLabel == nil) {
        _unapplyCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 5, 20, 20)];
        _unapplyCountLabel.textAlignment = NSTextAlignmentCenter;
        _unapplyCountLabel.font = [UIFont systemFontOfSize:11];
        _unapplyCountLabel.backgroundColor = [UIColor redColor];
        _unapplyCountLabel.textColor = [UIColor whiteColor];
        _unapplyCountLabel.layer.cornerRadius = _unapplyCountLabel.frame.size.height / 2;
        _unapplyCountLabel.hidden = YES;
        _unapplyCountLabel.clipsToBounds = YES;
    }
    
    return _unapplyCountLabel;
}
- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView                             = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle              = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor             = [UIColor whiteColor];
        _tableView.autoresizingMask            = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate                    = self;
        _tableView.dataSource                  = self;
        _tableView.tableFooterView             = [[UIView alloc] init];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexColor           = [UIColor colorWithHexString:ColorGold];
        
    }
    
    return _tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataSource count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
//        return 1;
    }
    
    return [[self.dataSource objectAtIndex:(section - 1)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableViewCell *cell;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
        if (cell == nil) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
        }
        
        cell.imageView.image = [UIImage imageNamed:@"newFriends"];
        cell.textLabel.text = NSLocalizedString(@"title.apply", @"Application and notification");
        [cell addSubview:self.unapplyCountLabel];
    }
    else{
        static NSString *CellIdentifier = @"ContactListCell";
        cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = self;
        }
        
        cell.indexPath = indexPath;
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"groupPrivateHeader"];
//            cell.username = NSLocalizedString(@"title.group", @"Group");
            cell.textLabel.text = NSLocalizedString(@"title.group", @"Group");
        }
//        else if (indexPath.section == 0 && indexPath.row == 2) {
//            cell.imageView.image = [UIImage imageNamed:@"groupPublicHeader"];
//            cell.username = NSLocalizedString(@"title.chatroomlist",@"chatroom list");
//        }
        else if (indexPath.section == 0 && indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"card_icon"];
//            cell.username = NSLocalizedString(@"title.robotlist",@"robot list");
            cell.textLabel.text = NSLocalizedString(@"title.cardlist",@"Card");
        }
        else{
            EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
            cell.username = buddy.username;
        }
    }
    
//    for(UIView *view in [tableView subviews]) {
//        if([view respondsToSelector:@selector(setIndexColor:)]) {
//            [view performSelector:@selector(setIndexColor:) withObject:[UIColor whiteColor]];
//        }
//    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
//        [self isViewLoaded];
    }
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        if ([buddy.username isEqualToString:loginUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notDeleteSelf", @"can't delete self") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        
        [self showHudInView:self.view hint:@""];
        //删除好友
        NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                                  @"target_id":[buddy.username stringByReplacingOccurrencesOfString:KH withString:@""]};
        [HttpService postWithUrlString:kDeleteFriendPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
            
            [self hideHud];
            int status = [responseData[HttpStatus] intValue];
            if (status == HttpStatusCodeSuccess) {
                EMError *error = nil;
                [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:&error];
                if (!error) {
                    [[EaseMob sharedInstance].chatManager removeConversationByChatter:buddy.username deleteMessages:YES append2Chat:YES];
                    
                    [tableView beginUpdates];
                    [[self.dataSource objectAtIndex:(indexPath.section - 1)] removeObjectAtIndex:indexPath.row];
                    [self.contactsSource removeObject:buddy];
                    [tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [tableView  endUpdates];
                    
                    [[IMUtils shareInstance] cacheBuddysToDiskWithRemoveUsername:buddy.username];
                }
                else{
                    [self showHint:[NSString stringWithFormat:NSLocalizedString(@"deleteFailed", @"Delete failed")]];
                    [tableView reloadData];
                }
                
            }else{
                [self showHint:StringCommonNetException];
            }
            
            
        } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self hideHud];
            [self showHint:StringCommonNetException];
        }];
        

    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[self.dataSource objectAtIndex:(section - 1)] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[self.dataSource objectAtIndex:(section - 1)] count] == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    return contentView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [self.sectionTitles count]; i++) {
//        if ([[self.dataSource objectAtIndex:i] count] > 0) {
        [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
//        }
    }
    return existTitles;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[ApplyViewController shareController] animated:YES];
        }
        else if (indexPath.row == 1)
        {
            if (_groupController == nil) {
                _groupController = [[GroupListViewController alloc] init];
            }
            else{
                [_groupController reloadDataSource];
            }
            [self.navigationController pushViewController:_groupController animated:YES];
        }
//        else if (indexPath.row == 2)
//        {
//            ChatroomListViewController *controller = [[ChatroomListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
        else if (indexPath.row == 2)
        {
//            RobotListViewController *controller = [[RobotListViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:controller animated:YES];
            CardListViewController * clvc = [[CardListViewController alloc] init];
            [self pushVC:clvc];
        }
    }
    else{
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        if (loginUsername && loginUsername.length > 0) {
            if ([loginUsername isEqualToString:buddy.username]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notChatSelf", @"can't talk to yourself") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
                
                return;
            }
        }
        
//        ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:buddy.username isGroup:NO];
//        chatVC.title = [[UserProfileManager sharedInstance] getNickNameWithUsername:buddy.username];
//        [self.navigationController pushViewController:chatVC animated:YES];
        OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
        opvc.uid = [[buddy.username stringByReplacingOccurrencesOfString:KH withString:@""] integerValue];
        [self pushVC:opvc];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex && _currentLongPressIndex) {
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(_currentLongPressIndex.section - 1)] objectAtIndex:_currentLongPressIndex.row];
        [self hideHud];
        [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Pleae wait...")];

        __weak typeof(self) weakSelf = self;
        [[EaseMob sharedInstance].chatManager asyncBlockBuddy:buddy.username relationship:eRelationshipBoth withCompletion:^(NSString *username, EMError *error){
            typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf hideHud];
            if (!error)
            {
                //由于加入黑名单成功后会刷新黑名单，所以此处不需要再更改好友列表
            }
            else
            {
                [strongSelf showHint:error.description];
            }
        } onQueue:nil];
    }
    _currentLongPressIndex = nil;
}

#pragma mark - BaseTableCellDelegate

- (void)cellImageViewLongPressAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0 && indexPath.row >= 1) {
//        // 群组，聊天室
//        return;
//    }
//    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
//    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
//    EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
//    if ([buddy.username isEqualToString:loginUsername])
//    {
//        return;
//    }
//
//    _currentLongPressIndex = indexPath;
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"friend.block", @"join the blacklist") otherButtonTitles:nil, nil];
//    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - private

- (NSMutableArray *)sortDataArray:(NSArray *)dataArray
{
    
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    //返回27，是a－z和＃
    NSInteger highSection = [self.sectionTitles count];
    //tableView 会被分成27个section
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    for (EMBuddy *buddy in dataArray) {
        //getUserName是实现中文拼音检索的核心，见NameIndex类
//        NSString *firstLetter = [ChineseToPinyin pinyinFromChineseString:[[UserProfileManager sharedInstance] getNickNameWithUsername:buddy.username]];
        NSString *firstLetter = [ChineseToPinyin pinyinFromChineseString:[[IMUtils shareInstance] getNickName:buddy.username]];
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:buddy];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EMBuddy *obj1, EMBuddy *obj2) {
            NSString *firstLetter1 = [ChineseToPinyin pinyinFromChineseString:[[IMUtils shareInstance] getNickName:obj1.username]];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [ChineseToPinyin pinyinFromChineseString:[[IMUtils shareInstance] getNickName:obj2.username]];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;
}

#pragma mark - dataSource

- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    [self.contactsSource removeAllObjects];

//    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSArray *buddyList = [[IMUtils shareInstance] getBuddys];
    //黑名单暂时不使用
    NSArray *blockList = [[EaseMob sharedInstance].chatManager blockedList];
    
    for (EMBuddy *buddy in buddyList) {
        if (![blockList containsObject:buddy.username]) {
            [self.contactsSource addObject:buddy];
        }
    }
    
//    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
//    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
//    if (loginUsername && loginUsername.length > 0) {
//        EMBuddy *loginBuddy = [EMBuddy buddyWithUsername:loginUsername];
//        [self.contactsSource addObject:loginBuddy];
//    }
    
    [self.dataSource addObjectsFromArray:[self sortDataArray:self.contactsSource]];
    
    [_tableView reloadData];
}

#pragma mark - action

- (void)reloadApplyView
{
    
    NSInteger count = [[InvitationManager sharedInstance] getUnread];
    
    if (count == 0) {
        self.unapplyCountLabel.hidden = YES;
    }
    else
    {
        NSString *tmpStr = [NSString stringWithFormat:@"%i", (int)count];
        CGSize size = [tmpStr sizeWithFont:self.unapplyCountLabel.font constrainedToSize:CGSizeMake(50, 20) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect = self.unapplyCountLabel.frame;
        rect.size.width = size.width > 20 ? size.width : 20;
        self.unapplyCountLabel.text = tmpStr;
        self.unapplyCountLabel.frame = rect;
        self.unapplyCountLabel.hidden = NO;
    }
}

- (void)reloadGroupView
{
    [self reloadApplyView];
    
    if (_groupController) {
        [_groupController reloadDataSource];
    }
}

- (void)addFriendAction
{
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:addController animated:YES];
}

#pragma mark - EMChatManagerBuddyDelegate
- (void)didUpdateBlockedList:(NSArray *)blockedList
{
    [self reloadDataSource];
}

@end
