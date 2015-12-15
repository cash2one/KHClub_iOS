//
//  CircleDetailViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/11/30.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleDetailViewController.h"
#import "ModifyCircleViewController.h"
#import "UIImageView+WebCache.h"
#import "QRcodeCardView.h"

typedef NS_ENUM(NSInteger, CircleDetailEnum) {
    CircleCover       = 0,
    CircleTitle       = 1,
    CircleInfo        = 2,
    CircleAddress     = 3,
    CircleManagerName = 4,
    CirclePhone       = 5,
    CircleWechat      = 6,
    CircleWeb         = 7
};

@interface CircleDetailViewController ()

@property (nonatomic, strong) UITableView  * tableView;
//修改按钮
@property (nonatomic, strong) CustomButton * modifyBtn;
//循环滚动集合
//@property (nonatomic, strong) UICollectionView * collectionView;
//page
//@property (nonatomic, strong) UIPageControl    * coverPageControl;

//@property (nonatomic, strong) NSMutableArray   * coverArray;

@end

@implementation CircleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWidget];
    [self configUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark- layout
- (void)initWidget
{
    self.tableView                              = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight) style:UITableViewStylePlain];
    self.tableView.delegate                     = self;
    self.tableView.dataSource                   = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    //修改圈子详情按钮
    self.modifyBtn = [[CustomButton alloc] init];
    [self.view addSubview:self.modifyBtn];
    
    [self.modifyBtn addTarget:self action:@selector(modifyCircle) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"News_CircleDetail_Title")];
   
    self.modifyBtn.frame           = CGRectMake(0, self.viewHeight-30, self.viewWidth, 30);
    self.modifyBtn.backgroundColor = [UIColor colorWithHexString:ColorGold];
    
    [self.modifyBtn setTitle:KHClubString(@"News_CircleDetail_ModifyCircle") forState:UIControlStateNormal];
    [self.modifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //如果不是自己 隐藏
    if (self.circleModel.managerId != [UserService sharedService].user.uid) {
        self.modifyBtn.hidden  = YES;
    }
}

#pragma mark- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld", indexPath.row]];
    if (!cell) {
        cell                = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell%ld", indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    switch (indexPath.row) {
        case CircleCover:
        {
            CustomImageView * coverImage   = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 150)];
            coverImage.contentMode         = UIViewContentModeScaleAspectFill;
            coverImage.layer.masksToBounds = YES;
            NSURL * url                    = [NSURL URLWithString:[ToolsManager completeUrlStr:self.circleModel.circle_cover_image]];
            [coverImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loading_default"]];
            [cell.contentView addSubview:coverImage];
        }
            break;
        case CircleTitle:
        {
            CustomLabel * titleLabel = [[CustomLabel alloc] init];
            titleLabel.frame         = CGRectMake(10, 10, 200, 15);
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.font          = [UIFont systemFontOfSize:15];
            titleLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
            
            titleLabel.text          = self.circleModel.circle_name;
            //底线
            UIView * line            = [[UIView alloc] initWithFrame:CGRectMake(0, 34, self.viewWidth, 1)];
            line.backgroundColor     = [UIColor colorWithHexString:ColorLightGary];
            [cell.contentView addSubview:line];
            //关注人数
            CustomImageView * likeImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(self.viewWidth-50, 11, 13, 13)];
            likeImageView.image             = [UIImage imageNamed:@"like_btn_normal"];
            CustomLabel * likeLabel         = [[CustomLabel alloc] initWithFrame:CGRectMake(self.viewWidth-30, 11, 28, 12)];
            likeLabel.font                  = [UIFont systemFontOfSize:12];
            likeLabel.text                  = [NSString stringWithFormat:@"%ld", self.circleModel.follow_quantity];
            
            [cell.contentView addSubview:titleLabel];
            [cell.contentView addSubview:likeImageView];
            [cell.contentView addSubview:likeLabel];
        }
            break;
        case CircleInfo:
        {
            //详情
            CustomLabel * infoTitleLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(10, 10, 200, 15)];
            infoTitleLabel.text          = KHClubString(@"News_CircleDetail_IntroTitle");
            infoTitleLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
            infoTitleLabel.font          = [UIFont systemFontOfSize:15];
            //内容
            CGSize introSize             = [ToolsManager getSizeWithContent:[@"   " stringByAppendingString:[ToolsManager emptyReturnNone:self.circleModel.circle_detail]] andFontSize:13 andFrame:CGRectMake(0, 0, self.viewWidth-20, MAXFLOAT)];
            CustomLabel * infoLabel      = [[CustomLabel alloc] initWithFrame:CGRectMake(10, infoTitleLabel.bottom+10, self.viewWidth-20, introSize.height)];
            infoLabel.lineBreakMode      = NSLineBreakByCharWrapping;
            infoLabel.numberOfLines      = 0;
            infoLabel.textColor          = [UIColor colorWithHexString:ColorDeepBlack];
            infoLabel.font               = [UIFont systemFontOfSize:13];
            infoLabel.text               = [@"   " stringByAppendingString:[ToolsManager emptyReturnNone:self.circleModel.circle_detail]];
            
            UIView * line                = [[UIView alloc] initWithFrame:CGRectMake(0, infoLabel.bottom+5, self.viewWidth, 1)];
            line.backgroundColor         = [UIColor colorWithHexString:ColorLightGary];
            
            [cell.contentView addSubview:infoLabel];
            [cell.contentView addSubview:infoTitleLabel];
            [cell.contentView addSubview:line];
            
        }
            break;
        case CircleAddress:
            [self factoryCellWithContent:self.circleModel.address andBackView:cell.contentView andImageName:@"icon_address"];
            break;
        case CircleManagerName:
            [self factoryCellWithContent:self.circleModel.manager_name andBackView:cell.contentView andImageName:@"icon_manager_name"];
            break;
        case CirclePhone:
            [self factoryCellWithContent:self.circleModel.phone_num andBackView:cell.contentView andImageName:@"icon_phone"];
            break;
        case CircleWechat:
        {
            [self factoryCellWithContent:self.circleModel.wx_num andBackView:cell.contentView andImageName:@"icon_weixin"];
            CustomImageView * qrcodeImageView = [[CustomImageView alloc] initWithFrame:CGRectMake(self.viewWidth-40, 5, 25, 25)];
            [qrcodeImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:self.circleModel.wx_qrcode]]];
            [cell.contentView addSubview:qrcodeImageView];
            
        }
            break;
        case CircleWeb:
            [self factoryCellWithContent:self.circleModel.circle_web andBackView:cell.contentView andImageName:@"icon_web"];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case CirclePhone:
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:KHClubString(@"Circle_CircleDetail_FirePhoneAlert") message:self.circleModel.phone_num delegate:self cancelButtonTitle:StringCommonCancel otherButtonTitles:StringCommonConfirm, nil];
            [alert show];
        }
            
            break;
        case CircleWechat:
        {
            QRcodeCardView * qcv = [[QRcodeCardView alloc] init];
            [qcv.imageView sd_setImageWithURL:[NSURL URLWithString:[ToolsManager completeUrlStr:self.circleModel.wx_qrcode]]];
            [qcv show];
        }
            break;
        case CircleWeb:
        {
            NSString * webUrl = self.circleModel.circle_web;
            if (![webUrl hasPrefix:@"http"]) {
                webUrl = [@"http://" stringByAppendingString:webUrl];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webUrl]];
        }
            break;
        default:
            break;
    }
}

#pragma mark- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 35;
    switch (indexPath.row) {
        case CircleCover:
            cellHeight = 150;
            break;
        case CircleTitle:
            break;
        case CircleInfo:
        {
            CGSize introSize = [ToolsManager getSizeWithContent:[@"   " stringByAppendingString:[ToolsManager emptyReturnNone:self.circleModel.circle_detail]] andFontSize:13 andFrame:CGRectMake(0, 0, self.viewWidth-20, MAXFLOAT)];
            cellHeight       = introSize.height + 41;
        }
            break;
        case CircleAddress:
            cellHeight = [self factoryCellGetHeightWithContent:self.circleModel.address];
            break;
        case CircleManagerName:
            cellHeight = [self factoryCellGetHeightWithContent:self.circleModel.manager_name];
            break;
        case CirclePhone:
            cellHeight = [self factoryCellGetHeightWithContent:self.circleModel.phone_num];
            break;
        case CircleWechat:
            cellHeight = [self factoryCellGetHeightWithContent:self.circleModel.wx_num];
            break;
        case CircleWeb:
            cellHeight = [self factoryCellGetHeightWithContent:self.circleModel.circle_web] + 30;
            break;
        default:
            break;
    }
    
    
    return cellHeight;
}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://15810710447"]];        
    }
}

//#pragma mark- UICollectionViewDataSource, UICollectionViewDelegate
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.coverArray.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    UIImageView * imageView     = [cell.contentView viewWithTag:100];
//    if (imageView == nil) {
//        imageView                     = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 150)];
//        imageView.tag                 = 100;
//        imageView.contentMode         = UIViewContentModeScaleAspectFill;
//        imageView.layer.masksToBounds = YES;
//        [cell.contentView addSubview:imageView];
//    }
//    
//    NSURL * url = [NSURL URLWithString:[ToolsManager completeUrlStr:self.coverArray[indexPath.row]]];
//    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loading_default"]];
//    
//    return cell;
//}

////循环滚动
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView == self.collectionView) {
//        if (self.coverArray.count > 0) {
//            NSInteger position = scrollView.contentOffset.x/self.viewWidth;
//            //位置变换 以及Page变换
//            if (position == 0) {
//                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.coverArray.count-2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//                self.coverPageControl.currentPage = self.coverArray.count - 2;
//            }else if (position == self.coverArray.count-1) {
//                
//                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//                self.coverPageControl.currentPage = 0;
//            }else{
//                self.coverPageControl.currentPage = position-1;
//            }
//        }
//    }
//}

#pragma mark- method response
- (void)modifyCircle
{
    ModifyCircleViewController * mcvc = [[ModifyCircleViewController alloc] init];
    mcvc.circleModel                  = self.circleModel;
    [mcvc setModifyBlock:^{
        [self.tableView reloadData];
    }];
    [self pushVC:mcvc];
}

#pragma mark- private method

//- (void)initScrollCollectionWithView:(UIView *)view
//{
//    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.scrollDirection              = UICollectionViewScrollDirectionHorizontal;
//    layout.itemSize                     = CGSizeMake(self.viewWidth, 150);
//    layout.minimumInteritemSpacing      = 0;
//    layout.minimumLineSpacing           = 0;
//    
//    //集合
//    self.collectionView                                = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, 150) collectionViewLayout:layout];
//    self.collectionView.bounces                        = YES;
//    self.collectionView.showsHorizontalScrollIndicator = NO;
//    self.collectionView.backgroundColor                = [UIColor colorWithHexString:ColorWhite];
//    self.collectionView.pagingEnabled                  = YES;
//    self.collectionView.delegate                       = self;
//    self.collectionView.dataSource                     = self;
//    self.collectionView.backgroundView                 = [[CustomImageView alloc] initWithImage:[UIImage imageNamed:@"topic_background"]];
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//    [view addSubview:self.collectionView];
//    
//    if (self.coverArray.count > 0) {
//        //page部分
//        UIView * pageBackView               = [[UIView alloc] initWithFrame:CGRectMake(0, 135, self.viewWidth, 15)];
//        pageBackView.backgroundColor        = [UIColor colorWithWhite:0.3 alpha:0.6];
//
//        self.coverPageControl               = [[UIPageControl alloc] init];
//        self.coverPageControl.numberOfPages = self.coverArray.count - 2;
//        self.coverPageControl.currentPage   = 0;
//        self.coverPageControl.enabled       = NO;
//        self.coverPageControl.frame         = CGRectMake(0, 0, self.viewWidth, 15);
//        [view addSubview:pageBackView];
//        [pageBackView addSubview:self.coverPageControl];
//    }
//    
////    if (self.coverArray.count > 0) {
////        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
////    }
//
//}

//循环滚动
//- (void)autoScroll
//{
//    NSInteger position = self.collectionView.contentOffset.x/self.viewWidth;
//    if(position < self.coverArray.count-1){
//        position ++;
//    }if (position >= self.coverArray.count-1) {
//        position = self.coverArray.count-1;
//    }
//    
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
//    
//}

//工厂方法处理 相同结构
- (void)factoryCellWithContent:(NSString *)content andBackView:(UIView *)backView andImageName:(NSString *)imageName
{
    
    CustomImageView * imageView = [[CustomImageView alloc] initWithFrame:CGRectMake(5, 8, 30, 20)];
    imageView.contentMode       = UIViewContentModeCenter;
    imageView.image             = [UIImage imageNamed:imageName];

    CustomLabel * label         = [[CustomLabel alloc] initWithFontSize:13];
    label.lineBreakMode         = NSLineBreakByCharWrapping;
    label.numberOfLines         = 0;
    label.frame                 = CGRectMake(40, 7, self.viewWidth-50, 20);
    label.textColor             = [UIColor colorWithHexString:ColorDeepBlack];
    CGSize size                 = [ToolsManager getSizeWithContent:[ToolsManager emptyReturnNone:content] andFontSize:13 andFrame:CGRectMake(0, 0, self.viewWidth-50, MAXFLOAT)];
    if (size.height > 20) {
        label.height = size.height;
    }
    label.text               = [ToolsManager emptyReturnNone:content];
    //线
    UIView * lineView        = [[UIView alloc] initWithFrame:CGRectMake(40, label.bottom+7, self.viewWidth-40, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:ColorLightGary];
    
    [backView addSubview:imageView];
    [backView addSubview:label];
    [backView addSubview:lineView];
}
//工厂方法获取 高度
- (CGFloat)factoryCellGetHeightWithContent:(NSString *)content
{
    CGSize size        = [ToolsManager getSizeWithContent:[ToolsManager emptyReturnNone:content] andFontSize:13 andFrame:CGRectMake(0, 0, self.viewWidth-50, MAXFLOAT)];
    CGFloat cellHeight = 35;
    if (size.height > 20) {
        cellHeight += size.height - 20;
    }
    
    return cellHeight;
}

//- (void)configData
//{
//    if (self.circleModel.circle_cover_image.length > 0) {
//        NSArray * tmpArr = [self.circleModel.circle_cover_image componentsSeparatedByString:@","];
//        self.coverArray  = [NSMutableArray arrayWithArray:tmpArr];
//        [self.coverArray insertObject:[self.coverArray[self.coverArray.count-1] copy] atIndex:0];
//        [self.coverArray insertObject:[self.coverArray[1] copy] atIndex:self.coverArray.count];
//        
//    }
//}

//- (CGFloat)factoryWithContent:(NSString *)content
//{
//    CGSize addressSize = [ToolsManager getSizeWithContent:[ToolsManager emptyReturnNone:content] andFontSize:16 andFrame:CGRectMake(0, 0, self.viewWidth-20, MAXFLOAT)];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
