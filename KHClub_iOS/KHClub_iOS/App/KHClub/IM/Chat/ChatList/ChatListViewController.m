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

#import "ChatListViewController.h"
#import "IMUtils.h"
#import "ChatListCell.h"
#import "EMSearchBar.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "RobotManager.h"
#import "RobotChatViewController.h"
#import "QRcodeViewController.h"
#import "SearchViewController.h"
#import "CreateGroupViewController.h"
#import "QRcodeCardView.h"
#import "UIImageView+WebCache.h"
#import "QRcodeCardView.h"

//@implementation EMConversation (search)
//
////根据用户昵称,环信机器人名称,群名称进行搜索
//- (NSString*)showName
//{
//    if (self.conversationType == eConversationTypeChat) {
//        if ([[RobotManager sharedInstance] isRobotWithUsername:self.chatter]) {
//            return [[RobotManager sharedInstance] getRobotNickWithUsername:self.chatter];
//        }
//        return [[UserProfileManager sharedInstance] getNickNameWithUsername:self.chatter];
//    } else if (self.conversationType == eConversationTypeGroupChat) {
//        if ([self.ext objectForKey:@"groupSubject"] || [self.ext objectForKey:@"isPublic"]) {
//           return [self.ext objectForKey:@"groupSubject"];
//        }
//    }
//    return self.chatter;
//}
//
//@end

@interface ChatListViewController ()<UITableViewDelegate,UITableViewDataSource, IChatManagerDelegate,ChatViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray        *dataSource;

@property (strong, nonatomic) UITableView           *tableView;
//@property (nonatomic, strong) EMSearchBar           *searchBar;
//@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) UIView                *networkStateView;
//弹出视图背景
@property (nonatomic, strong) UIView * popBackView;
//屏幕遮罩
@property (nonatomic, strong) UIView * screenCoverView;

//@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation ChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    [self removeEmptyConversationsFromDB];

    [self.view addSubview:self.tableView];
    [self networkStateView];
    
    [self setNavBarTitle:KHClubString(@"Common_Main_Msg")];
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshDataSource];
    [self registerNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

- (void)removeChatroomConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (conversation.conversationType == eConversationTypeChatRoom) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
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

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.view.frame.size.width, self.view.frame.size.height - kNavBarAndStatusHeight-kTabBarHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"chatListCell"];
    }
    
    return _tableView;
}

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - private

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];

    NSArray* sorte = [conversations sortedArrayUsingComparator:
           ^(EMConversation *obj1, EMConversation* obj2){
               EMMessage *message1 = [obj1 latestMessage];
               EMMessage *message2 = [obj2 latestMessage];
               if(message1.timestamp > message2.timestamp) {
                   return(NSComparisonResult)NSOrderedAscending;
               }else {
                   return(NSComparisonResult)NSOrderedDescending;
               }
           }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                if ([[IMUtils shareInstance] isCardMessage:didReceiveText]) {
                    ret = KHClubString(@"IM_ChatList_ACard");
                }else if ([[RobotManager sharedInstance] isRobotMenuMessage:lastMessage]) {
                    ret = [[RobotManager sharedInstance] getRobotMenuMessageDigest:lastMessage];
                } else {
                    ret = didReceiveText;
                }
            } break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[ location]");
            } break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

#pragma mark - TableViewDelegate & TableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    cell.name = conversation.chatter;
    if (conversation.conversationType == eConversationTypeChat) {
        cell.name = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.chatter];
        cell.groupId = nil;
        cell.placeholderImage = [UIImage imageNamed:@"chatListCellHead.png"];
    }
    else{
        NSString *imageName = @"groupPublicHeader";
        if (![conversation.ext objectForKey:@"groupSubject"] || ![conversation.ext objectForKey:@"isPublic"])
        {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    cell.name    = group.groupSubject;
                    cell.groupId = conversation.chatter;
                    imageName    = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";

                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.groupSubject forKey:@"groupSubject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                }
            }
        }
        else
        {
            cell.name    = [conversation.ext objectForKey:@"groupSubject"];
            cell.groupId = conversation.chatter;
            imageName    = [[conversation.ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
        }
        cell.placeholderImage = [UIImage imageNamed:imageName];
    }
    cell.detailMsg                   = [self subTitleMessageByConversation:conversation];
    cell.time                        = [self lastMessageTimeByConversation:conversation];
    cell.unreadCount                 = [self unreadMessageCountByConversation:conversation];
    cell.contentView.backgroundColor = [UIColor whiteColor];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    
    ChatViewController *chatController;
    NSString *title = conversation.chatter;
    if (conversation.conversationType != eConversationTypeChat) {
        if ([[conversation.ext objectForKey:@"groupSubject"] length])
        {
            title = [conversation.ext objectForKey:@"groupSubject"];
        }
        else
        {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    title = group.groupSubject;
                    break;
                }
            }
        }
    } else if (conversation.conversationType == eConversationTypeChat) {
//        title = [[UserProfileManager sharedInstance] getNickNameWithUsername:conversation.chatter];
        title = [[IMUtils shareInstance] getNickName:conversation.chatter];
    }
    
    NSString *chatter = conversation.chatter;
    if ([[RobotManager sharedInstance] isRobotWithUsername:chatter]) {
        chatController = [[RobotChatViewController alloc] initWithChatter:chatter
                                                    conversationType:conversation.conversationType];
        chatController.title = [[RobotManager sharedInstance] getRobotNickWithUsername:chatter];
    }else {
        chatController = [[ChatViewController alloc] initWithChatter:chatter
                                                    conversationType:conversation.conversationType];
        chatController.title = title;
    }
    
    chatController.delelgate = self;
    [self.navigationController pushViewController:chatController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - public

-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [_tableView reloadData];
    [self hideHud];
}

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }

}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self refreshDataSource];
}

- (void)didFinishedReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
}

#pragma mark - ChatViewControllerDelegate

// 根据环信id得到要显示头像路径，如果返回nil，则显示默认头像
- (NSString *)avatarWithChatter:(NSString *)chatter{
//    return @"http://img0.bdstatic.com/img/image/shouye/jianbihua0525.jpg";
    return nil;
}

// 根据环信id得到要显示用户名，如果返回nil，则默认显示环信id
- (NSString *)nickNameWithChatter:(NSString *)chatter{
    return chatter;
}

@end
