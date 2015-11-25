//
//  InformationChangeViewController.h
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/22.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"

/**
 *  个人需要修改的信息枚举类型
 */
typedef  NS_ENUM(NSInteger, ChangePersonalType){
    /**
     *  姓名
     */
    ChangePersonalName = 1,
    /**
     *  签名
     */
    ChangePersonalSign = 2,
    /**
     *  工作
     */
    ChangePersonalJob = 3,
    /**
     *  电话
     */
    ChangePersonalPhone = 4,
    /**
     *  地址
     */
    ChangePersonalAddress = 5,
    /**
     *  公司
     */
    ChangePersonalCompany = 6,
    /**
     *  邮箱
     */
    ChangePersonalEmail = 7,
    /**
     *  头衔1
     */
    ChangePersonalTitle1 = 9,
    /**
     *  头衔2
     */
    ChangePersonalTitle2 = 10,
    /**
     *  头衔3
     */
    ChangePersonalTitle3 = 11
};

typedef void(^ChangeBlock) (NSString * contentm, NSInteger state);

@interface InformationChangeViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic, assign) ChangePersonalType changeType;
@property (nonatomic, copy) NSString * content;
//设置回调Block
- (void)setChangeBlock:(ChangeBlock)block;

@end
