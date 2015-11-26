//
//  MyNewsListCell.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/23.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//


#import "MyNewsListCell.h"
#import "ImageModel.h"
#import "CommentModel.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "LikeModel.h"
#import "OtherPersonalViewController.h"
#import "NewsUtils.h"

@interface MyNewsListCell()

//新闻模型
@property (nonatomic, strong) NewsModel    * news;
//时间
@property (nonatomic, strong) CustomLabel  * timeLabel;
//内容
@property (nonatomic, strong) CustomLabel  * contentLabel;
//线view
@property (nonatomic, strong) UIView       * lineView;
//地址按钮
@property (nonatomic, strong) CustomButton * locationBtn;
//评论按钮
@property (nonatomic, strong) CustomButton * commentBtn;
//点赞按钮
@property (nonatomic, strong) CustomButton * likeBtn;

//可变视图数组 比如评论 图片
@property (nonatomic, strong) NSMutableArray * viewArr;

@end

@implementation MyNewsListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.viewArr                       = [[NSMutableArray alloc] init];
        //时间
        self.timeLabel                     = [[CustomLabel alloc] init];
        //内容
        self.contentLabel                  = [[CustomLabel alloc] init];
        //地址
        self.locationBtn                   = [[CustomButton alloc] init];
        //评论
        self.commentBtn                    = [[CustomButton alloc] init];
        //点赞
        self.likeBtn                       = [[CustomButton alloc] init];
        //线
        self.lineView                      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.locationBtn];
        [self.contentView addSubview:self.commentBtn];
        [self.contentView addSubview:self.likeBtn];
        [self.contentView addSubview:self.lineView];
        
        //点赞
        [self.likeBtn addTarget:self action:@selector(sendLikeClick) forControlEvents:UIControlEventTouchUpInside];
        //长按内容复制
        UILongPressGestureRecognizer * ges = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCopy:)];
        [self.contentLabel addGestureRecognizer:ges];
        
        [self configUI];
    }
    
    return self;
}

#pragma mark- layout
- (void)configUI
{
    self.selectionStyle                         = UITableViewCellSelectionStyleNone;
    //时间
    self.timeLabel.frame                        = CGRectMake(12, 8, 200, 20);
    self.timeLabel.font                         = [UIFont systemFontOfSize:17];
    self.timeLabel.textColor                    = [UIColor colorWithHexString:ColorDeepBlack];

    //内容
    self.contentLabel.frame                     = CGRectMake(self.timeLabel.x, self.timeLabel.bottom+5, [DeviceManager getDeviceWidth]-30, 0);
    self.contentLabel.userInteractionEnabled    = YES;
    self.contentLabel.numberOfLines             = 0;
    self.contentLabel.font                      = [UIFont systemFontOfSize:15];
    self.contentLabel.textColor                 = [UIColor colorWithHexString:ColorDeepBlack];

    //地理位置
    [self.locationBtn setTitleColor:[UIColor colorWithHexString:ColorLightBlue] forState:UIControlStateNormal];
    [self.locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    self.locationBtn.titleLabel.font            = [UIFont systemFontOfSize:14];
    self.locationBtn.frame                      = CGRectMake(self.timeLabel.x, 0, 190, 20);
    self.locationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    //评论按钮
    self.commentBtn.titleLabel.font             = [UIFont systemFontOfSize:14];
    self.commentBtn.titleEdgeInsets             = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"btn_comment_normal"] forState:UIControlStateNormal];
    [self.commentBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];

    //点赞
    self.likeBtn.titleLabel.font                = [UIFont systemFontOfSize:14];
    self.likeBtn.titleEdgeInsets                = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"btn_like_normal"] forState:UIControlStateNormal];
    [self.likeBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];

    self.lineView.backgroundColor               = [UIColor colorWithHexString:ColorLightWhite];
}

/*! 内容填充*/
- (void)setConentWithModel:(NewsModel *)news
{
    self.news = news;
    
    //清空可变数组
    [self.viewArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.viewArr removeAllObjects];
    
    //内容
    CGSize contentSize       = [ToolsManager getSizeWithContent:news.content_text andFontSize:15 andFrame:CGRectMake(0, 0, [DeviceManager getDeviceWidth]-30, MAXFLOAT)];
    if (news.content_text == nil || news.content_text.length < 1) {
        contentSize.height = 0;
    }
    self.contentLabel.height = contentSize.height;
    self.contentLabel.text   = news.content_text;
    
    //底部位置
    CGFloat bottomPosition   = self.contentLabel.bottom ;
    //图片处理
    if (news.image_arr.count == 1) {
        //一张图片放大
        ImageModel * imageModel          = news.image_arr[0];
        CGRect rect                      = [NewsUtils getRectWithSize:CGSizeMake(imageModel.width, imageModel.height)];
        rect.origin.x                    = self.timeLabel.x;
        rect.origin.y                    = self.contentLabel.bottom + 5;
        CustomImageView * imageView      = [[CustomImageView alloc] init];
        //加载单张
        NSURL * imageUrl                 = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, imageModel.sub_url]];
        UITapGestureRecognizer * tap     = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDetailClick:)];
        [imageView addGestureRecognizer:tap];
        [imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
        imageView.frame                  = rect;
        imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:imageView];
        //底部位置
        bottomPosition                   = imageView.bottom;
        //插入
        [self.viewArr addObject:imageView];
    }else{
        //多张图片九宫格
        NSArray * btnArr        = news.image_arr;
        for (int i=0; i<btnArr.count; i++) {
            ImageModel * imageModel          = news.image_arr[i];
            NSInteger columnNum              = i%3;
            NSInteger lineNum                = i/3;
            CustomImageView * imageView      = [[CustomImageView alloc] init];
            imageView.tag                    = i;
            imageView.userInteractionEnabled = YES;
            imageView.contentMode            = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds    = YES;
            CGFloat itemWidth                = [DeviceManager getDeviceWidth]/5.0;
            imageView.frame                  = CGRectMake(self.timeLabel.x+(itemWidth+10)*columnNum, self.contentLabel.bottom+5+(itemWidth+10)*lineNum, itemWidth, itemWidth);
            //加载缩略图
            NSURL * imageUrl                 = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, imageModel.sub_url]];
            UITapGestureRecognizer * tap     = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDetailClick:)];
            [imageView addGestureRecognizer:tap];
            [imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
            
            [self.contentView addSubview:imageView];
            //底部位置
            if (btnArr.count == i+1) {
                bottomPosition          = imageView.bottom;
            }
            //插入
            [self.viewArr addObject:imageView];
        }
    }
    
    //地址按钮 没有不显示
    if (news.location.length > 0) {
        NSString * locationTitle                  = [NSString stringWithFormat:@" %@", news.location];
        [self.locationBtn setTitle:locationTitle forState:UIControlStateNormal];
        self.locationBtn.y                        = bottomPosition+5;
        bottomPosition                            = self.locationBtn.bottom;
        self.locationBtn.hidden                   = NO;
    }else{
        self.locationBtn.hidden = YES;
    }
    
    //时间
    NSString * timeStr       = [ToolsManager compareCurrentTime:news.publish_date];
    self.timeLabel.text      = timeStr;
    
    //评论按钮
    self.commentBtn.frame    = CGRectMake([DeviceManager getDeviceWidth]-140, bottomPosition+5, 60, 25);
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%ld", news.comment_quantity] forState:UIControlStateNormal];
    [self.commentBtn setImage:[UIImage imageNamed:@"comment_btn_normal"] forState:UIControlStateNormal];
    
    //点赞按钮
    self.likeBtn.frame       = CGRectMake([DeviceManager getDeviceWidth]-80, bottomPosition+5, 60, 25);
    if (self.news.is_like) {
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
    }
    [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", news.like_quantity] forState:UIControlStateNormal];
    //游标
    bottomPosition             = self.commentBtn.bottom+9;
    
    //线
    self.lineView.frame        = CGRectMake(0, bottomPosition, [DeviceManager getDeviceWidth], 1);

}

#pragma mark- method response
//大头像点击
- (void)headClick:(CustomButton *)btn
{
    [self browsePersonalHome:self.news.uid];
}


//长按复制
- (void)longPressCopy:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(longPressContent:andGes:)]) {
            [self.delegate longPressContent:self.news andGes:longPress];
        }
    }
}

//复制
- (void)copyContnet:(id)sender
{
    //得到剪切板
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string        = self.news.content_text;
    debugLog(@"%@",[UIPasteboard generalPasteboard].string);
}
//取消menu
- (void)cancel:(id)sender
{}

//评论姓名点击
- (void)nameCommentTap:(UITapGestureRecognizer *)tap
{
    NSArray * commentArr     = self.news.comment_arr;
    CommentModel * model     = commentArr[tap.view.tag];
    [self browsePersonalHome:model.user_id];
}

//点赞头像点击
- (void)likeImageClick:(CustomButton *)btn
{
    LikeModel * like = self.news.like_arr[btn.tag];
    [self browsePersonalHome:like.user_id];
}

//图片点击
- (void)imageDetailClick:(UITapGestureRecognizer *) ges
{
    if ([self.delegate respondsToSelector:@selector(imageClick:index:)]) {
        [self.delegate imageClick:self.news index:ges.view.tag];
    }
}

//点赞或者取消赞点击
- (void)sendLikeClick {
    
    if ([self.delegate respondsToSelector:@selector(likeClick:likeOrCancel:)]) {
        BOOL likeOrCancel = YES;
        //先修改在进行网络请求
        if (self.news.is_like) {
            self.news.is_like = NO;
            likeOrCancel      = NO;
            self.news.like_quantity --;
            [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"btn_like_normal"] forState:UIControlStateNormal];
            [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
        }else{
            self.news.is_like = YES;
            self.news.like_quantity ++;
            [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
        }
        [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", self.news.like_quantity] forState:UIControlStateNormal];
        [self.delegate likeClick:self.news likeOrCancel:likeOrCancel];
    }
    
}

//浏览其他人的主页
- (void)browsePersonalHome:(NSInteger)userId
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    opvc.uid = userId;
    [((BaseViewController *)self.delegate) pushVC:opvc];
    
}

@end
