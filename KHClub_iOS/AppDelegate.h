//
//  AppDelegate.h
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/2.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YunBaService.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, IChatManagerDelegate>
{
    EMConnectionState _connectionState;
}
@property (strong, nonatomic) UIWindow *window;


@end

