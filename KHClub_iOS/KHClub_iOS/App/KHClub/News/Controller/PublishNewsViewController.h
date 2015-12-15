//
//  PublishNewsViewController.h
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/14.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"

/*! 发布状态页面*/
@interface PublishNewsViewController : BaseViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate>

/**
 *  发布成功后返回的VC 柯以为空
 */
@property (nonatomic, strong) UIViewController * returnVC;

@end
