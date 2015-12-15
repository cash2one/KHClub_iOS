//
//  PublishNewsViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/14.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "PublishNewsViewController.h"
#import "BrowseImageViewController.h"
#import "ChoiceLocationViewController.h"
#import "UIImageView+WebCache.h"
#import "ZYQAssetPickerController.h"
#import <CoreFoundation/CoreFoundation.h>
#import "ChoiceCircleViewController.h"

@interface PublishNewsViewController ()<ZYQAssetPickerControllerDelegate>

//图片按钮数组
@property (nonatomic, strong) NSMutableArray      * imageArr;
/**
 *  顶部背景视图
 */
@property (strong, nonatomic) UIView              * topBackView;

@property (strong, nonatomic) PlaceHolderTextView *textView;

@property (strong, nonatomic) CustomButton        *addImageBtn;

@property (strong, nonatomic) CustomButton        *locationBtn;

@property (nonatomic ,copy  ) NSString            * location;

//图片宽度
@property (nonatomic, assign) CGFloat             itemWidth;

@end

@implementation PublishNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.location = @"";
    self.imageArr = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];

    [self initWidget];
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- layout

- (void)initWidget
{
    self.topBackView = [[UIView alloc] init];
    self.addImageBtn = [[CustomButton alloc] init];
    self.locationBtn = [[CustomButton alloc] init];
    self.textView    = [[PlaceHolderTextView alloc] init];
    
    [self.view  addSubview:self.topBackView];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.locationBtn];
    [self.view addSubview:self.addImageBtn];
}

- (void)configUI {
    
    [self setNavBarTitle:KHClubString(@"News_Publish_PublishNews")];
    
    __weak typeof(self) sself = self;
    [self.navBar setRightBtnWithContent:KHClubString(@"News_Publish_Send") andBlock:^{
        [sself publishNewClick];
    }];
    [self.navBar.rightBtn setTitleColor:[UIColor colorWithHexString:ColorWhite] forState:UIControlStateNormal];
    [self.navBar.rightBtn setTitleColor:[UIColor colorWithHexString:ColorLightGary] forState:UIControlStateHighlighted];
    
    self.topBackView.backgroundColor = [UIColor whiteColor];
    
    self.textView.frame              = CGRectMake(kCenterOriginX((self.viewWidth-60)), kNavBarAndStatusHeight+30, self.viewWidth-60, 130);
    self.textView.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
    self.textView.layer.borderWidth  = 1;
    self.textView.layer.borderColor  = [UIColor colorWithHexString:ColorGold].CGColor;
    [self.textView setPlaceHolder:KHClubString(@"News_Publish_EnterContent")];
    
    //计算宽度
    self.itemWidth         = (self.viewWidth-90)/4.0;
    self.addImageBtn.frame = CGRectMake(30, self.textView.bottom+20, self.itemWidth, self.itemWidth);
    [self.addImageBtn setBackgroundImage:[UIImage imageNamed:@"add_picture"] forState:UIControlStateNormal];
    [self.addImageBtn addTarget:self action:@selector(addImageClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.topBackView.frame = CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.addImageBtn.bottom+10-kNavBarAndStatusHeight);
    
    //地理位置按钮
    self.locationBtn.frame                      = CGRectMake(0, self.addImageBtn.bottom+20, self.viewWidth, 40);
    self.locationBtn.titleLabel.font            = [UIFont systemFontOfSize:14];
    self.locationBtn.backgroundColor            = [UIColor whiteColor];
    self.locationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.locationBtn setImage:[UIImage imageNamed:@"location_content_image"] forState:UIControlStateNormal];
    [self.locationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    [self.locationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 35, 0, 0)];
    [self.locationBtn setTitle:KHClubString(@"News_Publish_Where") forState:UIControlStateNormal];
    [self.locationBtn setTitleColor:[UIColor colorWithHexString:ColorLightBlack] forState:UIControlStateNormal];
    [self.locationBtn addTarget:self action:@selector(locationClick:) forControlEvents:UIControlEventTouchUpInside];

    
}

#pragma mark- ZYQAssetPickerControllerDelegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    for (int i=0; i<assets.count; i++) {
        ALAsset *asset=assets[i];
        UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        UIImage * image = [ImageHelper getBigImage:tempImg];
        [self handleImage:image];
    }
}

#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage * image = [ImageHelper getBigImage:info[UIImagePickerControllerOriginalImage]];
    [self handleImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- Action Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //选照片
    if (buttonIndex != 2) {
        
        if (buttonIndex == 1) {
            
            ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
            picker.maximumNumberOfSelection  = 9-self.imageArr.count;
            picker.assetsFilter              = [ALAssetsFilter allPhotos];
            picker.showEmptyGroups           = NO;
            picker.delegate                  = self;
            picker.selectionFilter           = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                    NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                    return duration >= 5;
                } else {
                    return YES;
                }
            }];
            [self presentViewController:picker animated:YES completion:NULL];
            
        }
        
        if (buttonIndex == 0) {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:^{
            }];
        }
        
    }
    
}

#pragma mark- method response
- (void)addImageClick:(id)sender {
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:KHClubString(@"Personal_PersonalSetting_Icon") delegate:self cancelButtonTitle:StringCommonCancel destructiveButtonTitle:nil otherButtonTitles:KHClubString(@"Common_Camera"), KHClubString(@"Common_Gallery"), nil];
    [sheet showInView:self.view];
}

- (void)locationClick:(id)sender {
    ChoiceLocationViewController * clvc = [[ChoiceLocationViewController alloc] init];
    [clvc setChoickBlock:^(NSString *str) {
        if (str.length < 1) {
            [self.locationBtn setTitle:KHClubString(@"News_Publish_Where") forState:UIControlStateNormal];
            return ;
        }
        [self.locationBtn setTitle:str forState:UIControlStateNormal];
        self.location = str;
    }];
    [self pushVC:clvc];
}

//图片查看大图
- (void)bigImageClick:(UITapGestureRecognizer *)ges
{
    BrowseImageViewController * bivc = [[BrowseImageViewController alloc] init];
    bivc.canDelete                   = YES;
    bivc.image                       = ((CustomImageView *)ges.view).image;
    bivc.num                         = [self.imageArr indexOfObject:ges.view];
    __weak typeof(self) sself        = self;
    [bivc setDeleteBlock:^(NSInteger num) {
        [sself deleteImageWithNum:num];
    }];
    [self pushVC:bivc];
    
}

//发表状态
- (void)publishNewClick
{

    if (self.textView.text.length < 1 && self.imageArr.count < 1) {
        [self showHint:KHClubString(@"News_Publish_ContentEmpty")];
        return;
    }
    
    if (self.textView.text.length > 140) {
        [self showHint:KHClubString(@"News_Publish_CotentTooLong")];
        return;
    }
    
    ChoiceCircleViewController * ccvc = [[ChoiceCircleViewController alloc] init];
    
    __weak ChoiceCircleViewController * weakC = ccvc;
    [ccvc setCircleBlock:^(NSArray *circles) {

        //确定后进行网络上传
        NSDictionary * params = @{@"uid":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                                  @"content_text":self.textView.text,
                                  @"location":self.location,
                                  @"circles":[circles componentsJoinedByString:@","]};
        
        NSMutableArray * files = [[NSMutableArray alloc] init];
        
        //头像处理
        int timeInterval = [NSDate date].timeIntervalSince1970;
        //图片数组处理
        if (self.imageArr.count > 0) {
            for (CustomImageView * imageView in self.imageArr) {
                NSString * fileName = [NSString stringWithFormat:@"%ld%d.png", [UserService sharedService].user.uid, timeInterval++];
                UIImage * image = [ImageHelper getBigImage:imageView.image];
                [files addObject:@{FileDataKey:UIImageJPEGRepresentation(image, 0.9),FileNameKey:fileName}];
            }
        }
        
        debugLog(@"%@", kPublishNewsPath);
        [self showLoading:nil];
        [HttpService postFileWithUrlString:kPublishNewsPath params:params files:files andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
            debugLog(@"%@", responseData);
            int status = [responseData[HttpStatus] intValue];
            if (status == HttpStatusCodeSuccess) {
                
                [self hideLoading];
                //发送发送成功通知
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_PUBLISH_NEWS object:nil];
                if (self.returnVC != nil) {
                    [weakC popTo:self.returnVC];
                }else{
                    [weakC popToTab];
                }
            }else{
                [weakC showFail];
            }
        } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakC showException];
        }];
        
    }];
    [self pushVC:ccvc];


}

#pragma mark- private Method
//处理图片
- (void)handleImage:(UIImage *)image
{
    
    CustomImageView * imageView      = [[CustomImageView alloc] init];
    imageView.layer.masksToBounds    = YES;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap     = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageClick:)];
    [imageView addGestureRecognizer:tap];
    imageView.contentMode            = UIViewContentModeScaleAspectFill;
    imageView.image                  = image;
    [self.view addSubview:imageView];
    
    [self moveImageView:imageView];
}

//修改btn的位置
- (void)moveImageView:(CustomImageView *)imageView
{
    [self.imageArr addObject:imageView];
    imageView.frame        = self.addImageBtn.frame;
    NSInteger columnNum    = self.imageArr.count%4;
    NSInteger lineNum      = self.imageArr.count/4;
    
    self.addImageBtn.frame = CGRectMake(30+(self.itemWidth+10)*columnNum, self.textView.bottom+20+(self.itemWidth+10)*lineNum, self.itemWidth, self.itemWidth);

    //位置
    [self.locationBtn setY:self.addImageBtn.bottom+20];
    [self.topBackView setHeight:self.addImageBtn.bottom+10-kNavBarAndStatusHeight];
    
    if (self.imageArr.count >= 9) {
        self.addImageBtn.hidden = YES;
    }else{
        self.addImageBtn.hidden = NO;
    }
}

//上传成功后缓存图片
- (void)cacheImageWithFiles:(NSArray *)files andResultUrls:(NSDictionary *)results
{

    for (int i=0; i<files.count; i++) {
        NSDictionary * filesDic = files[i];
        NSString * imagePath    = results[filesDic[FileNameKey]];
        NSURL * imageurl        = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, imagePath]];
        //缓存图片
        UIImage * image         = [UIImage imageWithData:filesDic[FileDataKey]];
        [[SDWebImageManager sharedManager] saveImageToCache:image forURL:imageurl];
    }

}

//删除图片
- (void)deleteImageWithNum:(NSInteger)num
{
    //删除该iv
    CustomImageView * deleteImageView = self.imageArr[num];
    [self.imageArr removeObject:deleteImageView];
    [deleteImageView removeFromSuperview];
    
    //重新排位
    NSArray * fileArr = [self.imageArr copy];
    [self.imageArr removeAllObjects];
    self.addImageBtn.frame  = CGRectMake(30, self.textView.bottom+20, self.itemWidth, self.itemWidth);
    for (CustomImageView * imageView in fileArr) {
        [self moveImageView:imageView];
    }
    
}

#pragma mark- override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.textView resignFirstResponder];
}


@end
