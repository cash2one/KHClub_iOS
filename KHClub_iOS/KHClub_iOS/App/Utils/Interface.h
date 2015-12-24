//
//  Interface.h
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/8.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#ifndef JLXCSNS_iOS_Interface_h
#define JLXCSNS_iOS_Interface_h

//192.168.1.108 120.25.213.171 114.215.95.23 127.0.0.1
//附件
#define kAttachmentAddr @"http://114.215.95.23/khclub_php/Uploads/"
//IP
#define kRootAddr @"http://114.215.95.23/khclub_php/"
//home
#define kHomeAddr @"http://114.215.95.23/khclub_php/index.php/Home/MobileApi"

#define kUserProtocolPath @"http://www.pinweihuanqiu.com/license.html"

//分享名片地址
#define kShareCardWeb [kRootAddr stringByAppendingString:@"index.php/Home/WX/cardDetail"]
//分享圈子地址
#define kShareCircleWeb [kRootAddr stringByAppendingString:@"index.php/Home/WX/details"]

//分享网站地址
#define kShareWeb @"http://www.khclub.sg/"

////////////////////////////////////////////////登录注册////////////////////////////////////////////////
//是否有该用户
#define kIsUserPath [kHomeAddr stringByAppendingString:@"/isUser"]

//注册
#define kRegisterUserPath [kHomeAddr stringByAppendingString:@"/registerUser"]

//找回密码
#define kFindPwdPath [kHomeAddr stringByAppendingString:@"/findPwd"]

//登录
#define kLoginUserPath [kHomeAddr stringByAppendingString:@"/loginUser"]

////////////////////////////////////////////////首页'说说'部分////////////////////////////////////////////////
//发布状态
#define kPublishNewsPath [kHomeAddr stringByAppendingString:@"/publishNews"]

//状态新闻列表
#define kNewsListPath [kHomeAddr stringByAppendingString:@"/newsList"]

//发送评论
#define kSendCommentPath [kHomeAddr stringByAppendingString:@"/sendComment"]

//删除评论
#define kDeleteCommentPath [kHomeAddr stringByAppendingString:@"/deleteComment"]

//点赞或者取消赞
#define kLikeOrCancelPath [kHomeAddr stringByAppendingString:@"/likeOrCancel"]

//新闻详情
#define kNewsDetailPath [kHomeAddr stringByAppendingString:@"/newsDetail"]
////////////////////////////////////////////////首页'圈子'部分////////////////////////////////////////////////
// 圈子列表 废弃
#define kGetCircleListPath [kHomeAddr stringByAppendingString:@"/getCircleList"]

// 创建圈子
#define kPostNewCirclePath [kHomeAddr stringByAppendingString:@"/postNewCircle"]

// 修改圈子信息
#define kModifyCirclePath [kHomeAddr stringByAppendingString:@"/modifyCircle"]

// 圈子列表
#define kGetPersonalCircleListPath [kHomeAddr stringByAppendingString:@"/getPersonalCircleList"]

// 圈子主页列表
#define kGetCircleHomeListPath [kHomeAddr stringByAppendingString:@"/getCircleHomeList"]

// 我的圈子封面列表
//#define kGetMyCircleCoverPath [kHomeAddr stringByAppendingString:@"/getMyCircleCover"]

// 我的圈子列表
#define kGetMyCircleListPath [kHomeAddr stringByAppendingString:@"/getMyCircleList"]

// 关注或者取消关注圈子
#define kFollowOrUnfollowCirclePath [kHomeAddr stringByAppendingString:@"/followOrUnfollowCircle"]

// 圈达人列表 http://114.215.95.23/khclub_php/index.php/Home/MobileApi/getCircleMembers?circle_id=2
#define kGetCircleMembersPath [kHomeAddr stringByAppendingString:@"/getCircleMembers"]

// 我关注的圈子列表
#define kGetMyFollowCircleListPath [kHomeAddr stringByAppendingString:@"/getMyFollowCircleList"]

// 发布圈子公告
#define kPostNewNoticePath [kHomeAddr stringByAppendingString:@"/postNewNotice"]

// 获取公告列表
#define kGetNoticeListPath [kHomeAddr stringByAppendingString:@"/getNoticeList"]

// 发公告评论
#define kSendNoticeCommentPath [kHomeAddr stringByAppendingString:@"/sendNoticeComment"]

// 公告点赞
#define kNoticeLikeOrCancelPath [kHomeAddr stringByAppendingString:@"/noticeLikeOrCancel"]

////////////////////////////////////////////////个人信息////////////////////////////////////////////////
//修改个人信息
#define kChangePersonalInformationPath [kHomeAddr stringByAppendingString:@"/changePersonalInformation"]

//修改有可见状态的个人信息
#define kChangePersonalInformationStatePath [kHomeAddr stringByAppendingString:@"/changePersonalInformationState"]

//获取用户二维码
#define kGetUserQRCodePath [kHomeAddr stringByAppendingString:@"/getUserQRCode"]

//修改个人信息中的图片 如背景图 头像
#define kChangeInformationImagePath [kHomeAddr stringByAppendingString:@"/changeInformationImage"]

//个人信息中 获取最新动态的三张图片
#define kGetNewsCoverListPath [kHomeAddr stringByAppendingString:@"/getNewsCoverList"]

//个人信息中 用户发布过的状态列表
#define kUserNewsListPath [kHomeAddr stringByAppendingString:@"/userNewsList"]

//个人信息 删除状态
#define kDeleteNewsListPath [kHomeAddr stringByAppendingString:@"/deleteNews"]

//个人信息 查看别人的信息
#define kPersnalInformationPath [kHomeAddr stringByAppendingString:@"/personalInfo"]

//个人信息 获取个人额外信息
#define kGetPersonalExtraInformationPath [kHomeAddr stringByAppendingString:@"/getPersonalExtraInformation"]

//个人信息 修改个人额外信息
#define kChangePersonalExtraInformationPath [kHomeAddr stringByAppendingString:@"/changePersonalExtraInformation"]

//举报用户
#define kReportOffencePath [kHomeAddr stringByAppendingString:@"/reportOffence"]

//////////////////////////////////////////IM模块//////////////////////////////////////////
//添加好友
#define kAddFriendPath [kHomeAddr stringByAppendingString:@"/addFriend"]

//删除好友
#define kDeleteFriendPath [kHomeAddr stringByAppendingString:@"/deleteFriend"]

//添加好友备注
#define kAddRemarkPath [kHomeAddr stringByAppendingString:@"/addRemark"]

//获取图片和名字
#define kGetImageAndNamePath [kHomeAddr stringByAppendingString:@"/getImageAndName"]

// 创建圈子
#define kCreateGroupPath [kHomeAddr stringByAppendingString:@"/createGroup"]

// 获取群组图片和名字
#define kGetGroupImageAndNameAndQrcodePath [kHomeAddr stringByAppendingString:@"/getGroupImageAndNameAndQrcode"]

// 更新群组名字
#define kUpdateGroupNamePath [kHomeAddr stringByAppendingString:@"/updateGroupName"]

// 更新群组封面
#define kUpdateGroupCoverPath [kHomeAddr stringByAppendingString:@"/updateGroupCover"]

//获取全部好友
#define kGetAllFriendsListPath [kHomeAddr stringByAppendingString:@"/getAllFriendsList"]

//////////////////////////////////////////发现模块//////////////////////////////////////////

//获取联系人用户
#define kGetContactUserPath [kHomeAddr stringByAppendingString:@"/getContactUser"]

//搜索用户列表
#define kFindUserListPath [kHomeAddr stringByAppendingString:@"/findUserList"]

//搜索用户或者群组
#define kFindUserOrGroupPath [kHomeAddr stringByAppendingString:@"/findUserOrGroup"]

//////////////////////////////////////通讯录部分//////////////////////////////////////////
// 收藏名片
#define kCollectCardPath [kHomeAddr stringByAppendingString:@"/collectCard"]
// 取消收藏名片
#define kDeleteCardPath [kHomeAddr stringByAppendingString:@"/deleteCard"]
// 获取所收藏的名片列表
#define kGetCardListPath [kHomeAddr stringByAppendingString:@"/getCardList"]
//// ////////////////////////////主菜，搜索，二维码，创建群///////////////////////////////////
// 获取所收藏的名片列表
#define kFindUserOrGroupPath [kHomeAddr stringByAppendingString:@"/findUserOrGroup"]




#endif
