//
//  IMUtils.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/10.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NAMEKEY @"name"
#define AVATARKEY @"avatar"

#define GROUP_AVATARKEY @"groupAvatar"
#define GROUP_QRCODEKEY @"groupQrcode"


@class UserIMEntity;

//IM协助工具
@interface IMUtils : NSObject


+ (instancetype)shareInstance;

/**
 *  根据username获取相应user
 *
 *  @param username
 *
 *  @return 用户实体模型
 */
- (UserIMEntity *)getUserInfoWithUsername:(NSString *)username;

/**
 *  获取名字
 *
 *  @param username
 *
 *  @return 名字
 */
- (NSString *)getNickName:(NSString *)username;

/**
 *  设置用户头像
 *
 *  @param username
 *  @param imageView 需要设置头像的imageView
 */
- (void)setUserAvatarWith:(NSString *)username and:(UIImageView *)imageView;

/**
 *  设置自己的头像
 *
 *  @param imageView 需要设置头像的imageView
 */
- (void)setCurrentUserAvatar:(UIImageView *)imageView;

/**
 *  设置用户名字
 *
 *  @param username
 *  @param nameLabel 填写内容的label
 */
- (void)setUserNickWith:(NSString *)username and:(UILabel *)nameLabel;

/**
 *  设置自己的名字
 *
 *  @param nameLabel 填写内容的label
 */
- (void)setCurrentUserNick:(UILabel *)nameLabel;

/**
 *  保存名字到本地
 *
 *  @param name 名字
 */
- (void)setUserNickWithStr:(NSString *)name andUsername:(NSString *)username;

/**
 *  好友列表缓存到本地
 */
- (void)cacheBuddysToDisk;

/**
 *  删除好友后更新
 */
- (void)cacheBuddysToDiskWithRemoveUsername:(NSString *)username;

/**
 *  获取本地好友列表
 *
 *  @return arr
 */
- (NSArray *)getBuddys;

/**
 *  保存群组名字
 *
 *  @param imageName
 *  @param groupName
 */
- (void)saveGroupImage:(NSString *)imageName groupName:(NSString *)groupName;

/**
 *  保存群组二维码
 *
 *  @param qrCode
 *  @param groupName 
 */
- (void)saveQrCode:(NSString *)qrCode groupName:(NSString *)groupName;

/**
 *  设置用户头像
 *
 *  @param groupId
 *  @param imageView 需要设置头像的imageView
 */
- (void)setGroupImageWith:(NSString *)groupId and:(UIImageView *)imageView;

/**
 *  设置用户名字
 *
 *  @param groupId
 *  @param nameLabel 填写内容的label
 */
- (void)setGroupNameWith:(NSString *)groupId and:(UILabel *)nameLabel andGroupTitle:(NSString *)title;

/**
 *  设置二维码
 *
 *  @param groupId
 *  @param imageView 需要设置二维码的imageView
 */
- (void)setGroupQrCodeWith:(NSString *)groupId and:(UIImageView *)imageView;


@end


/**
 *  用户IM信息模型
 */
@interface UserIMEntity : NSObject

//用户名
@property (nonatomic,strong) NSString *username;
//姓名
@property (nonatomic,strong) NSString *nickname;
//头像
@property (nonatomic,strong) NSString *imageUrl;

@end