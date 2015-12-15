//
//  ModifyCircleViewController.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/11.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "BaseViewController.h"
#import "CircleModel.h"

typedef void (^ModifyCircleBlock) (void);

/**
 *  修改圈子页面
 */
@interface ModifyCircleViewController : BaseViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//圈子模型
@property (nonatomic, strong) CircleModel * circleModel;


- (void)setModifyBlock:(ModifyCircleBlock)block;

@end
