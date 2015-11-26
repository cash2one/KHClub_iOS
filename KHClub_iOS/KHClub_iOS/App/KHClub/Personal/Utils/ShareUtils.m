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
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
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
    
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupWeChatParamsByText:content title:title url:url thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}
//微信朋友圈
+ (void)shareWechatMomentsWithUser:(UserModel *)user
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
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
    
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:url
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [shareParams SSDKSetupWeChatParamsByText:content title:title url:url thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}
//QQ
+ (void)shareQQWithUser:(UserModel *)user
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

    [shareParams SSDKSetupQQParamsByText:content title:title url:url thumbImage:nil image:image type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQQFriend];

    [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}

//QQ空间
+ (void)shareQzoneWithUser:(UserModel *)user
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
    
    [shareParams SSDKSetupQQParamsByText:content title:title url:url thumbImage:nil image:image type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQZone];
    
    [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
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
    
    [shareParams SSDKSetupWeChatParamsByText:content title:title url:url thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}
//微信朋友圈
+ (void)shareWechatMomentsWithTitle:(NSString *)titleText
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
    
    [shareParams SSDKSetupWeChatParamsByText:content title:title url:url thumbImage:nil image:image musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}
//QQ
+ (void)shareQQWithTitle:(NSString *)titleText
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

    [shareParams SSDKSetupQQParamsByText:content title:title url:url thumbImage:nil image:image type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQQFriend];

    [ShareSDK share:SSDKPlatformSubTypeQQFriend parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
}
//QQ空间
+ (void)shareQzoneWithTitle:(NSString *)titleText
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
    
    [shareParams SSDKSetupQQParamsByText:content title:title url:url thumbImage:nil image:image type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQZone];
    
    [ShareSDK share:SSDKPlatformSubTypeQZone parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
    }];
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


@end
