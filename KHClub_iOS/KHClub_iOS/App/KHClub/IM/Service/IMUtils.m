//
//  IMUtils.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/10.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "IMUtils.h"
#import "HttpService.h"
#import "UIImageView+EMWebCache.h"

@implementation IMUtils
{
    NSUserDefaults * _defaults;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static IMUtils * instance;
    dispatch_once(&onceToken, ^{
        instance = [[IMUtils alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

/**
 *  根据username获取相应user
 *
 *  @param username
 *
 *  @return 用户实体模型
 */
- (UserIMEntity *)getUserInfoWithUsername:(NSString *)username
{
    if (username.length < 1) {
        return nil;
    }
    
    //返回的模型
    UserIMEntity * user = [[UserIMEntity alloc] init];
    user.username       = username;
    //姓名
    NSString * name     = [_defaults objectForKey:[username stringByAppendingString:NAMEKEY]];
    user.nickname       = name;
    //头像
    NSString * avatar   = [_defaults objectForKey:[username stringByAppendingString:AVATARKEY]];
    user.imageUrl       = avatar;
    
    return user;
}

/**
 *  获取名字
 *
 *  @param username
 *
 *  @return 名字
 */
- (NSString *)getNickName:(NSString *)username
{
    UserIMEntity * user = [self getUserInfoWithUsername:username];
    
//    //网络请求获取新的
//    NSString * url = [NSString stringWithFormat:@"%@?user_id=%@&self_id=%ld",kGetImageAndNamePath, [username stringByReplacingOccurrencesOfString:KH withString:@""], [UserService sharedService].user.uid];
//    //获取图片 姓名
//    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
//        
//        int status = [responseData[HttpStatus] intValue];
//        if (status == HttpStatusCodeSuccess) {
//            NSDictionary * result = responseData[HttpResult];
//            NSString * name = result[@"name"];
//            NSString * headImage = result[@"head_sub_image"];
//            if (headImage.length > 0) {
//                headImage = [kAttachmentAddr stringByAppendingString:headImage];
//            }
//            [_defaults setObject:name forKey:[username stringByAppendingString:NAMEKEY]];
//            [_defaults setObject:headImage forKey:[username stringByAppendingString:AVATARKEY]];
//            [_defaults synchronize];
//        }
//        
//    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }];
    
    return [ToolsManager emptyReturnNone:user.nickname];
}

/**
 *  设置用户头像
 *
 *  @param username
 *  @param imageView 需要设置头像的imageView
 */
- (void)setUserAvatarWith:(NSString *)username and:(UIImageView *)imageView
{
    if ([username isEqualToString:KH_ROBOT]) {
        imageView.image = [UIImage imageNamed:@"Icon"];
        return;
    }
    
    //获取
    UserIMEntity * user = [self getUserInfoWithUsername:username];
    if (user) {
        //如果本地有的话
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.imageUrl] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    }
    //网络请求获取新的
    NSString * url = [NSString stringWithFormat:@"%@?user_id=%@&self_id=%ld",kGetImageAndNamePath, [username stringByReplacingOccurrencesOfString:KH withString:@""], [UserService sharedService].user.uid];
    //获取图片 姓名
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            NSDictionary * result = responseData[HttpResult];
            NSString * name = result[@"name"];
            NSString * headImage = result[@"head_sub_image"];
            if (headImage.length > 0) {
                headImage = [kAttachmentAddr stringByAppendingString:headImage];
            }
            [_defaults setObject:name forKey:[username stringByAppendingString:NAMEKEY]];
            [_defaults setObject:headImage forKey:[username stringByAppendingString:AVATARKEY]];
            [_defaults synchronize];
            [imageView sd_setImageWithURL:[NSURL URLWithString:headImage] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

/**
 *  设置自己的头像
 *
 *  @param imageView 需要设置头像的imageView
 */
- (void)setCurrentUserAvatar:(UIImageView *)imageView
{
    [imageView sd_setImageWithURL:[NSURL URLWithString:[UserService sharedService].user.head_sub_image] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
}

/**
 *  设置用户名字
 *
 *  @param username
 *  @param nameLabel 填写内容的label
 */
- (void)setUserNickWith:(NSString *)username and:(UILabel *)nameLabel
{
    if ([username isEqualToString:KH_ROBOT]) {
        nameLabel.text = KHClubString(@"Personal_Personal_RobotTitle");
        return;
    }
    
    //获取
    UserIMEntity * user = [self getUserInfoWithUsername:username];
    
    if (user) {
        //如果本地有的话
        [nameLabel setText:[ToolsManager emptyReturnNone:user.nickname]];
    }
    //网络请求获取新的
    NSString * url = [NSString stringWithFormat:@"%@?user_id=%@&self_id=%ld",kGetImageAndNamePath, [username stringByReplacingOccurrencesOfString:KH withString:@""], [UserService sharedService].user.uid];
    //获取图片 姓名
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            NSDictionary * result = responseData[HttpResult];
            NSString * name = result[@"name"];
            NSString * headImage = result[@"head_sub_image"];
            if (headImage.length > 0) {
                headImage = [kAttachmentAddr stringByAppendingString:headImage];
            }
            
            [_defaults setObject:name forKey:[username stringByAppendingString:NAMEKEY]];
            [_defaults setObject:headImage forKey:[username stringByAppendingString:AVATARKEY]];
            [_defaults synchronize];
            [nameLabel setText:[ToolsManager emptyReturnNone:name]];
            
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

/**
 *  设置自己的名字
 *
 *  @param nameLabel 填写内容的label
 */
- (void)setCurrentUserNick:(UILabel *)nameLabel
{
    [nameLabel setText:[ToolsManager emptyReturnNone:[UserService sharedService].user.name]];
}

- (void)setUserNickWithStr:(NSString *)name andUsername:(NSString *)username
{
    [_defaults setObject:name forKey:[username stringByAppendingString:NAMEKEY]];
    [_defaults synchronize];
}

- (void)cacheBuddysToDisk
{

    NSArray *buddys = [[EaseMob sharedInstance].chatManager buddyList];
    
    if (buddys.count > 0) {
        NSMutableArray * tmpBuddys = [[NSMutableArray alloc] init];
        for (EMBuddy * bd in buddys) {
            if (bd.followState == eEMBuddyFollowState_FollowedBoth) {
                [tmpBuddys addObject:bd.username];
            }
        }
        //本地缓存
        NSString * friendsPath =  [PATH_OF_DOCUMENT stringByAppendingFormat:@"/friends.plist"];
        [tmpBuddys writeToFile:friendsPath atomically:YES];
    }
}

- (void)cacheBuddysToDiskWithRemoveUsername:(NSString *)username
{
    NSMutableArray * arr   = [[NSMutableArray alloc] initWithContentsOfFile:[PATH_OF_DOCUMENT stringByAppendingFormat:@"/friends.plist"]];
    [arr removeObject:username];
    //本地缓存
    NSString * friendsPath = [PATH_OF_DOCUMENT stringByAppendingFormat:@"/friends.plist"];
    [arr writeToFile:friendsPath atomically:YES];
}

- (NSArray *)getBuddys
{
    NSString * friendsPath  = [PATH_OF_DOCUMENT stringByAppendingFormat:@"/friends.plist"];
    NSArray * arr           = [NSArray arrayWithContentsOfFile:friendsPath];
    NSMutableArray * buddys = [[NSMutableArray alloc] init];
    for (NSString * username in arr) {
        [buddys addObject:[EMBuddy buddyWithUsername:username]];
    }
    return buddys;
}


- (void)saveGroupImage:(NSString *)imageName groupName:(NSString *)groupName
{
    [_defaults setObject:[ToolsManager completeUrlStr:imageName] forKey:[groupName stringByAppendingString:GROUP_AVATARKEY]];
    [_defaults synchronize];
}

- (void)saveQrCode:(NSString *)qrCode groupName:(NSString *)groupName
{
    [_defaults setObject:[kRootAddr stringByAppendingString:qrCode] forKey:[groupName stringByAppendingString:GROUP_QRCODEKEY]];
    [_defaults synchronize];
}

- (void)setGroupImageWith:(NSString *)groupId and:(UIImageView *)imageView
{
    //获取
    NSString * path = [_defaults objectForKey:[groupId stringByAppendingString:GROUP_AVATARKEY]];
    //如果本地有的话
    [imageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"groups_icon"]];
    //网络请求获取新的
    NSString * url = [NSString stringWithFormat:@"%@?group_id=%@",kGetGroupImageAndNameAndQrcodePath, groupId];
    //获取图片 名字
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            NSDictionary * result  = responseData[HttpResult];
            NSString * groupCover  = result[@"group_cover"];
            NSString * groupQrcode = result[@"group_qr_code"];
            [self saveQrCode:groupQrcode groupName:groupId];
            [self saveGroupImage:groupCover groupName:groupId];
            if ([[ToolsManager completeUrlStr:groupCover] compare:path] != NSOrderedSame) {
                //设置
                [imageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:groupCover]] placeholderImage:[UIImage imageNamed:@"groups_icon"]];
            }
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)setGroupQrCodeWith:(NSString *)groupId and:(UIImageView *)imageView
{
    //获取
    NSString * path = [_defaults objectForKey:[groupId stringByAppendingString:GROUP_QRCODEKEY]];
    //如果本地有的话
    [imageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"loading_default"]];
    //网络请求获取新的
    NSString * url = [NSString stringWithFormat:@"%@?group_id=%@",kGetGroupImageAndNameAndQrcodePath, groupId];
    //获取图片 名字
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            NSDictionary * result  = responseData[HttpResult];
            NSString * groupCover  = result[@"group_cover"];
            NSString * groupQrcode = result[@"group_qr_code"];

            [self saveQrCode:groupQrcode groupName:groupId];
            [self saveGroupImage:groupCover groupName:groupId];
            //设置
            [imageView sd_setImageWithURL:[NSURL URLWithString:[kRootAddr stringByAppendingString:groupQrcode]] placeholderImage:[UIImage imageNamed:@"loading_default"]];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)setGroupNameWith:(NSString *)groupId and:(UILabel *)nameLabel andGroupTitle:(NSString *)title 
{
    nameLabel.text = title;
    
    //网络请求获取新的
    NSString * url = [NSString stringWithFormat:@"%@?group_id=%@",kGetGroupImageAndNameAndQrcodePath, groupId];
    //获取图片 名字
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            NSDictionary * result  = responseData[HttpResult];
            NSString * groupCover  = result[@"group_cover"];
            NSString * groupQrcode = result[@"group_qr_code"];
            NSString * name        = result[@"group_name"];
            if (name.length > 0) {
                nameLabel.text         = name;
            }
            [self saveQrCode:groupQrcode groupName:groupId];
            [self saveGroupImage:groupCover groupName:groupId];

        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

@end


@implementation UserIMEntity

@end