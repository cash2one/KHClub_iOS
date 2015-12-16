//
//  ShareUtils.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/26.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

/**
 *  这个类现在代码冗余 回头改
 */
@interface ShareUtils : NSObject

//微信
+ (void)shareWechatWithUser:(UserModel *)user;
//微信朋友圈
+ (void)shareWechatMomentsWithUser:(UserModel *)user;
//QQ
+ (void)shareQQWithUser:(UserModel *)user;
//QQ空间
+ (void)shareQzoneWithUser:(UserModel *)user;
//新浪微博
+ (void)shareSinaWithUser:(UserModel *)user;

//微信 
+ (void)shareWechatWithTitle:(NSString *)titleText;
//微信朋友圈
+ (void)shareWechatMomentsWithTitle:(NSString *)titleText;
//QQ
+ (void)shareQQWithTitle:(NSString *)titleText;
//QQ空间
+ (void)shareQzoneWithTitle:(NSString *)titleText;
//新浪微博
+ (void)shareSinaWithTitle:(NSString *)titleText;

//微信
+ (void)shareWechatWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID;
//微信朋友圈
+ (void)shareWechatMomentsWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID;
//QQ
+ (void)shareQQWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID;
//QQ空间
+ (void)shareQzoneWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID;

@end
