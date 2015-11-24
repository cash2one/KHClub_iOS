//
//  CardModel.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardModel : NSObject

/*! 用户Id*/
@property (nonatomic, assign) NSInteger uid;

/*! 用户姓名*/
@property (nonatomic, copy) NSString * name;

/*! 头像缩略图*/
@property (nonatomic, copy) NSString * head_sub_image;

/*! 公司*/
@property (nonatomic, copy) NSString * company_name;

/*! 职位*/
@property (nonatomic, copy) NSString * job;

@end
