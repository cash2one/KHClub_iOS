//
//  SecondLoginViewController.h
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/13.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"

@interface SecondLoginViewController : BaseViewController<UITextFieldDelegate>

//用户名
@property (nonatomic, copy) NSString * username;
//区域码
@property (nonatomic, copy) NSString * areaCode;

@end
