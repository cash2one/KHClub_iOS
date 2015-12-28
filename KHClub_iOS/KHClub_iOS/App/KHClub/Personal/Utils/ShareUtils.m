//
//  ShareUtils.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/26.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "ShareUtils.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

@implementation ShareUtils

//微信
+ (void)shareWechatWithUser:(UserModel *)user
{
    id image;
    if (user.head_sub_image.length > 0) {
        image = [NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]];
    }else{
        image = [UIImage imageNamed:@"Icon"];
    }
    NSArray* imageArray = @[image];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%ld", kShareCardWeb, user.uid]];
    NSString * title = KHClubString(@"Personal_Personal_ExchangeCard");
    NSString * content = user.name.length > 0 ? user.name : @"KHClub";
    content = [content stringByAppendingFormat:@" | %@\n%@", user.job, user.company_name];
    
    [self shareWechatWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//微信朋友圈
+ (void)shareWechatMomentsWithUser:(UserModel *)user
{
    id image;
    if (user.head_sub_image.length > 0) {
        image = [NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]];
    }else{
        image = [UIImage imageNamed:@"Icon"];
    }
    NSArray* imageArray = @[image];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%ld", kShareCardWeb, user.uid]];
    NSString * title = KHClubString(@"Personal_Personal_ExchangeCard");
    NSString * content = user.name.length > 0 ? user.name : @"KHClub";
    content = [content stringByAppendingFormat:@" | %@\n%@", user.job, user.company_name];
    
    [self shareWechatMomentsWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//QQ
+ (void)shareQQWithUser:(UserModel *)user
{
    id image;
    if (user.head_sub_image.length > 0) {
        image                            = [NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]];
    }else{
        image                            = [UIImage imageNamed:@"Icon"];
    }
    NSArray* imageArray              = @[image];

    NSURL * url                      = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%ld", kShareCardWeb, user.uid]];
    NSString * title                 = KHClubString(@"Personal_Personal_ExchangeCard");
    NSString * content               = user.name.length > 0 ? user.name : @"KHClub";
    content                          = [content stringByAppendingFormat:@" | %@\n%@", user.job, user.company_name];

    [self shareQQWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}

//QQ空间
+ (void)shareQzoneWithUser:(UserModel *)user
{

    id image;
    if (user.head_sub_image.length > 0) {
        image                            = [NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]];
    }else{
        image                            = [UIImage imageNamed:@"Icon"];
    }
    NSArray* imageArray              = @[image];

    NSURL * url                      = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%ld", kShareCardWeb, user.uid]];
    NSString * title                 = KHClubString(@"Personal_Personal_ExchangeCard");
    NSString * content               = user.name.length > 0 ? user.name : @"KHClub";
    content                          = [content stringByAppendingFormat:@" | %@\n%@", user.job, user.company_name];

    [self shareQzoneWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}

//新浪微博
+ (void)shareSinaWithUser:(UserModel *)user
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    id image;
    if (user.head_sub_image.length > 0) {
        image                            = [NSURL URLWithString:[ToolsManager completeUrlStr:user.head_sub_image]];
    }else{
        image                            = [UIImage imageNamed:@"Icon"];
    }
    NSArray* imageArray              = @[image];

    NSURL * url                      = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%ld", kShareCardWeb, user.uid]];
    NSString * title                 = KHClubString(@"Personal_Personal_ExchangeCard");
    NSString * content               = user.name.length > 0 ? user.name : @"KHClub";
    content                          = [content stringByAppendingFormat:@" | %@\n%@", user.job, user.company_name];
    
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupSinaWeiboShareParamsByText:content
                                               title:title
                                               image:image
                                                 url:nil
                                            latitude:0
                                           longitude:0
                                            objectID:nil
                                                type:SSDKContentTypeImage];
    
    [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}

+ (void)shareWechatWithTitle:(NSString *)titleText
{
    id image                         = [UIImage imageNamed:@"Icon"];
    NSArray * imageArray             = @[image];
    
    NSURL * url                      = [NSURL URLWithString:kShareWeb];
    NSString * title                 = KHClubString(@"Common_App_Name");
    NSString * content               = titleText.length > 0 ? titleText : @"KHClub";
    
    [self shareWechatWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//微信朋友圈
+ (void)shareWechatMomentsWithTitle:(NSString *)titleText
{
    id image                         = [UIImage imageNamed:@"Icon"];
    NSArray * imageArray             = @[image];
    
    NSURL * url                      = [NSURL URLWithString:kShareWeb];
    NSString * title                 = KHClubString(@"Common_App_Name");
    NSString * content               = titleText.length > 0 ? titleText : @"KHClub";
    
    [self shareWechatMomentsWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//QQ
+ (void)shareQQWithTitle:(NSString *)titleText
{
    id image                         = [UIImage imageNamed:@"Icon"];
    NSArray * imageArray             = @[image];
    
    NSURL * url                      = [NSURL URLWithString:kShareWeb];
    NSString * title                 = KHClubString(@"Common_App_Name");
    NSString * content               = titleText.length > 0 ? titleText : @"KHClub";

    [self shareQQWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//QQ空间
+ (void)shareQzoneWithTitle:(NSString *)titleText
{
    id image                         = [UIImage imageNamed:@"Icon"];
    NSArray * imageArray             = @[image];
    
    NSURL * url                      = [NSURL URLWithString:kShareWeb];
    NSString * title                 = KHClubString(@"Common_App_Name");
    NSString * content               = titleText.length > 0 ? titleText : @"KHClub";
    
    [self shareQzoneWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//新浪微博
+ (void)shareSinaWithTitle:(NSString *)titleText
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    id image                         = [UIImage imageNamed:@"Icon"];
    NSArray * imageArray             = @[image];
    
    NSURL * url                      = [NSURL URLWithString:kShareWeb];
    NSString * title                 = KHClubString(@"Common_App_Name");
    NSString * content               = titleText.length > 0 ? titleText : @"KHClub";
    
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupSinaWeiboShareParamsByText:content
                                               title:title
                                               image:image
                                                 url:nil
                                            latitude:0
                                           longitude:0
                                            objectID:nil
                                                type:SSDKContentTypeImage];
    
    [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}
//分享圈子信息
+ (void)shareWechatWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID
{
    id image;
    if (imagePath.length > 0) {
        image                        = [NSURL URLWithString:[ToolsManager completeUrlStr:imagePath]];
    }else{
        image                        = [UIImage imageNamed:@"Icon"];
    }
    NSArray * imageArray             = @[image];
    
    NSURL * url                      = [NSURL URLWithString:[NSString stringWithFormat:@"%@?circle_id=%ld", kShareCircleWeb, circleID]];
    NSString * title                 = circleName;
    NSString * content               = name.length > 0 ? name : @"KHClub";
    
    [self shareWechatWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//微信朋友圈
+ (void)shareWechatMomentsWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID
{
    id image;
    if (imagePath.length > 0) {
        image                        = [NSURL URLWithString:[ToolsManager completeUrlStr:imagePath]];
    }else{
        image                        = [UIImage imageNamed:@"Icon"];
    }
    NSArray * imageArray             = @[image];

    NSURL * url                      = [NSURL URLWithString:[NSString stringWithFormat:@"%@?circle_id=%ld", kShareCircleWeb, circleID]];
    NSString * title                 = circleName;
    NSString * content               = name.length > 0 ? name : @"KHClub";
    
    [self shareWechatMomentsWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}
//QQ
+ (void)shareQQWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID
{
    id image;
    if (imagePath.length > 0) {
        image                        = [NSURL URLWithString:[ToolsManager completeUrlStr:imagePath]];
    }else{
        image                        = [UIImage imageNamed:@"Icon"];
    }
    NSArray * imageArray             = @[image];
    NSURL * url                      = [NSURL URLWithString:[NSString stringWithFormat:@"%@?circle_id=%ld", kShareCircleWeb, circleID]];

    NSString * title                 = circleName;
    NSString * content               = name.length > 0 ? name : @"KHClub";
    [self shareQQWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];

}
//QQ空间
+ (void)shareQzoneWithTitle:(NSString *)circleName andManagerName:(NSString *)name andImage:(NSString *)imagePath andCircleID:(NSInteger)circleID
{
    id image;
    if (imagePath.length > 0) {
        image                            = [NSURL URLWithString:[ToolsManager completeUrlStr:imagePath]];
    }else{
        image                            = [UIImage imageNamed:@"Icon"];
    }
    NSArray * imageArray             = @[image];
    
    NSURL * url                      = [NSURL URLWithString:[NSString stringWithFormat:@"%@?circle_id=%ld", kShareCircleWeb, circleID]];
    NSString * title                 = circleName;
    NSString * content               = name.length > 0 ? name : @"KHClub";
    
    [self shareQzoneWithText:content andImageArr:imageArray andUrl:url andTitle:title andImage:image];
}

+ (void)shareWechatWithText:(NSString *)content andImageArr:(NSArray *)imageArray andUrl:(NSURL *)url andTitle:(NSString *)title andImage:(UIImage *)image
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupWeChatParamsByText:content title:title url:url thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}

+ (void)shareWechatMomentsWithText:(NSString *)content andImageArr:(NSArray *)imageArray andUrl:(NSURL *)url andTitle:(NSString *)title andImage:(UIImage *)image
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupWeChatParamsByText:content title:title url:url thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}

+ (void)shareQQWithText:(NSString *)content andImageArr:(NSArray *)imageArray andUrl:(NSURL *)url andTitle:(NSString *)title andImage:(UIImage *)image
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupQQParamsByText:content title:title url:url thumbImage:nil image:image type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQQFriend];
    
    [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}

+ (void)shareQzoneWithText:(NSString *)content andImageArr:(NSArray *)imageArray andUrl:(NSURL *)url andTitle:(NSString *)title andImage:(UIImage *)image
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupQQParamsByText:content title:title url:url thumbImage:nil image:image type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQZone];
    
    [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}

@end
