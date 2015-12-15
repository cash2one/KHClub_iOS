//
//  QRcodeCardView.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/20.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "QRcodeCardView.h"
#import "MBProgressHUD.h"
@implementation QRcodeCardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame                             = CGRectMake(0, 0, [DeviceManager getDeviceWidth], [DeviceManager getDeviceHeight]);
        self.backgroundColor                   = [UIColor colorWithWhite:0.5 alpha:0.5];

        UITapGestureRecognizer * tap           = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [self addGestureRecognizer:tap];

        UIView * backView                      = [[UIView alloc] initWithFrame:CGRectMake(kCenterOriginX(200), kNavBarAndStatusHeight+100, 200, 200)];
        backView.backgroundColor               = [UIColor whiteColor];

        self.imageView                         = [[CustomImageView alloc] initWithFrame:CGRectMake(25, 25, 150, 150)];
        self.imageView.userInteractionEnabled  = YES;
        UILongPressGestureRecognizer * longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImage:)];
        [self.imageView addGestureRecognizer:longGes];
        
        CustomLabel * titleLabel = [[CustomLabel alloc] initWithFontSize:15];
        titleLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
        titleLabel.text          = KHClubString(@"Message_GroupDetail_QRcodeCard");
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.frame         = CGRectMake(0, 0, 200, 30);
        
        [self addSubview:backView];
        [backView addSubview:self.imageView];
        [backView addSubview:titleLabel];
    }
    return self;
}

- (void)show
{
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss:(id)sender
{
    [self removeFromSuperview];
}


#pragma mark- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (self.imageView.image) {
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

#pragma mark- method response
- (void)longPressImage:(UILongPressGestureRecognizer *)ges
{
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:StringCommonCancel destructiveButtonTitle:nil otherButtonTitles:StringCommonSave, nil];
        [sheet showInView:self];
    }
    
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfo
{
    //显示提示信息
    UIView *view       = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView     = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ToastFinish"]];
    // Set custom view mode
    hud.mode           = MBProgressHUDModeCustomView;
    hud.labelText      = KHClubString(@"News_BrowseImage_SaveOk");
    [hud show:YES];
    [hud hide:YES afterDelay:1];
    
}


@end
