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

#import "ApplyViewController.h"
#import "OtherPersonalViewController.h"
#import "IMUtils.h"
#import "ApplyFriendCell.h"
#import "InvitationManager.h"

static ApplyViewController *controller = nil;

@interface ApplyViewController ()<ApplyFriendCellDelegate>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation ApplyViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSource = [[NSMutableArray alloc] init];
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginName = [loginInfo objectForKey:kSDKUsername];
        if(loginName && [loginName length] > 0)
        {
            NSArray * applyArray = [[InvitationManager sharedInstance] applyEmtitiesWithloginUser:loginName];
            [self.dataSource addObjectsFromArray:applyArray];
        }
    }
    return self;
}

+ (instancetype)shareController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] init];
    });
    
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavBarTitle:NSLocalizedString(@"title.apply", @"Application and notification")];
    
    self.tableView            = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    // Uncomment the following line to preserve selection between presentations.
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadDataSourceFromLocalDB];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[InvitationManager sharedInstance] clearUnread];
    //发通知
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TAB_BADGE object:nil];
    
//    [self.tableView reloadData];
}
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUntreatedApplyCount" object:nil];
//}

#pragma mark - getter

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (NSString *)loginUsername
{
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    return [loginInfo objectForKey:kSDKUsername];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplyFriendCell";
    ApplyFriendCell *cell = (ApplyFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[ApplyFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(self.dataSource.count > indexPath.row)
    {
        ApplyEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        if (entity) {
            cell.indexPath = indexPath;
            ApplyStyle applyStyle = [entity.style intValue];
            if (applyStyle == ApplyStyleGroupInvitation) {
                cell.titleLabel.text = NSLocalizedString(@"title.groupApply", @"Group Notification");
                cell.headerImageView.image = [UIImage imageNamed:@"groupPrivateHeader"];
            }
            else if (applyStyle == ApplyStyleJoinGroup)
            {
                cell.titleLabel.text = NSLocalizedString(@"title.groupApply", @"Group Notification");
                cell.headerImageView.image = [UIImage imageNamed:@"groupPrivateHeader"];
            }
            else if(applyStyle == ApplyStyleFriend){
                NSString * username = [entity.applicantUsername stringByReplacingOccurrencesOfString:KH withString:@""];
//                cell.titleLabel.text = entity.applicantUsername;
                [[IMUtils shareInstance] setUserNickWith:username and:cell.titleLabel];
                [[IMUtils shareInstance] setUserAvatarWith:username and:cell.headerImageView];
//                cell.headerImageView.image = [UIImage imageNamed:@"chatListCellHead"];
            }
            cell.contentLabel.text = entity.reason;
        }
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ApplyEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
    return [ApplyFriendCell heightWithContent:entity.reason];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ApplyFriendCellDelegate

- (void)applyCellAddFriendAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        [self showHudInView:self.view hint:NSLocalizedString(@"sendingApply", @"sending apply...")];
        
        ApplyEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        ApplyStyle applyStyle = [entity.style intValue];
        EMError *error;
        
        /*if (applyStyle == ApplyStyleGroupInvitation) {
            [[EaseMob sharedInstance].chatManager acceptInvitationFromGroup:entity.groupId error:&error];
        }
        else */if (applyStyle == ApplyStyleJoinGroup)
        {
            //群组
            [[EaseMob sharedInstance].chatManager acceptApplyJoinGroup:entity.groupId groupname:entity.groupSubject applicant:entity.applicantUsername error:&error];
            
            [self hideHud];
            if (!error) {
                [self.dataSource removeObject:entity];
                NSString *loginUsername = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
                [[InvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
                [self.tableView reloadData];
            }
            else{
                [self showHint:NSLocalizedString(@"acceptFail", @"accept failure")];
            }
            
        }
        else if(applyStyle == ApplyStyleFriend){
            //kAddFriendPath
            NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                                      @"target_id":[entity.applicantUsername stringByReplacingOccurrencesOfString:KH withString:@""]};
            
            debugLog(@"%@ %@", kAddFriendPath, params);
            //添加好友
            [HttpService postWithUrlString:kAddFriendPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
                
                [self hideHud];
                int status = [responseData[HttpStatus] intValue];
                if (status == HttpStatusCodeSuccess) {
                    EMError * error;
                    //环信添加
                    [[EaseMob sharedInstance].chatManager acceptBuddyRequest:entity.applicantUsername error:&error];
                    if (!error) {
                        [self.dataSource removeObject:entity];
                        NSString *loginUsername = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
                        [[InvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
                        [self.tableView reloadData];
                        //进入主页
                        OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
                        opvc.uid                           = [[entity.applicantUsername stringByReplacingOccurrencesOfString:KH withString:@""] integerValue];
                        opvc.newFriend                     = YES;
                        [self pushVC:opvc];
                    }
                    else{
                        [self showHint:NSLocalizedString(@"acceptFail", @"accept failure")];
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
}

- (void)applyCellRefuseFriendAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row < [self.dataSource count]) {
//        [self showHudInView:self.view hint:NSLocalizedString(@"sendingApply", @"sending apply...")];
//        ApplyEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
//        ApplyStyle applyStyle = [entity.style intValue];
//        EMError *error;
//        
//        if (applyStyle == ApplyStyleGroupInvitation) {
//            [[EaseMob sharedInstance].chatManager rejectInvitationForGroup:entity.groupId toInviter:entity.applicantUsername reason:@""];
//        }
//        else if (applyStyle == ApplyStyleJoinGroup)
//        {
//            [[EaseMob sharedInstance].chatManager rejectApplyJoinGroup:entity.groupId groupname:entity.groupSubject toApplicant:entity.applicantUsername reason:nil];
//        }
//        else if(applyStyle == ApplyStyleFriend){
//            [[EaseMob sharedInstance].chatManager rejectBuddyRequest:entity.applicantUsername reason:@"" error:&error];
//        }
//        
//        [self hideHud];
//        if (!error) {
//            [self.dataSource removeObject:entity];
//            NSString *loginUsername = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
//            [[InvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
//            
//            [self.tableView reloadData];
//        }
//        else{
//            [self showHint:NSLocalizedString(@"rejectFail", @"reject failure")];
//        }
//    }
}

#pragma mark - public

- (void)addNewApply:(NSDictionary *)dictionary
{
    if (dictionary && [dictionary count] > 0) {
        
        NSString *applyUsername = [dictionary objectForKey:@"username"];
        ApplyStyle style = [[dictionary objectForKey:@"applyStyle"] intValue];
        
        if (applyUsername && applyUsername.length > 0) {
            for (int i = ((int)[_dataSource count] - 1); i >= 0; i--) {
                ApplyEntity *oldEntity = [_dataSource objectAtIndex:i];
                ApplyStyle oldStyle = [oldEntity.style intValue];
                if (oldStyle == style && [applyUsername isEqualToString:oldEntity.applicantUsername]) {
                    if(style != ApplyStyleFriend)
                    {
                        NSString *newGroupid = [dictionary objectForKey:@"groupname"];
                        if (newGroupid || [newGroupid length] > 0 || [newGroupid isEqualToString:oldEntity.groupId]) {
                            break;
                        }
                    }
                    
                    oldEntity.reason = [dictionary objectForKey:@"applyMessage"];
                    [_dataSource removeObject:oldEntity];
                    [_dataSource insertObject:oldEntity atIndex:0];
                    [self.tableView reloadData];
                    
                    return;
                }
            }
            
            //new apply
            ApplyEntity * newEntity= [[ApplyEntity alloc] init];
            newEntity.applicantUsername = [dictionary objectForKey:@"username"];
            newEntity.style = [dictionary objectForKey:@"applyStyle"];
            newEntity.reason = [dictionary objectForKey:@"applyMessage"];
            
            NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
            NSString *loginName = [loginInfo objectForKey:kSDKUsername];
            newEntity.receiverUsername = loginName;
            
            NSString *groupId = [dictionary objectForKey:@"groupId"];
            newEntity.groupId = (groupId && groupId.length > 0) ? groupId : @"";
            
            NSString *groupSubject = [dictionary objectForKey:@"groupname"];
            newEntity.groupSubject = (groupSubject && groupSubject.length > 0) ? groupSubject : @"";
            
            NSString *loginUsername = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
            //增加未读
            [[InvitationManager sharedInstance] addInvitation:newEntity loginUser:loginUsername];
            [[InvitationManager sharedInstance] addUnread];
            
            [_dataSource insertObject:newEntity atIndex:0];
            [self.tableView reloadData];

        }
    }
}

- (void)loadDataSourceFromLocalDB
{
    [_dataSource removeAllObjects];
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginName = [loginInfo objectForKey:kSDKUsername];
    if(loginName && [loginName length] > 0)
    {
        
        NSArray * applyArray = [[InvitationManager sharedInstance] applyEmtitiesWithloginUser:loginName];
        [self.dataSource addObjectsFromArray:applyArray];
        
        [self.tableView reloadData];
    }
}

- (void)clear
{
    [_dataSource removeAllObjects];
    [self.tableView reloadData];
}

@end
