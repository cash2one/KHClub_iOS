//
//  NewsListCell.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/17.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "NewsListCell.h"
#import "ImageModel.h"
#import "CommentModel.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "LikeModel.h"
#import "OtherPersonalViewController.h"
#import "NewsUtils.h"

@interface NewsListCell()

//新闻模型
@property (nonatomic, strong) NewsModel    * news;
//头像
@property (nonatomic, strong) CustomButton * headImageBtn;
//姓名
@property (nonatomic, strong) CustomLabel  * nameLabel;
//时间
@property (nonatomic, strong) CustomLabel  * timeLabel;
//职位 | 公司
@property (nonatomic, strong) CustomButton * jobBtn;
//内容
@property (nonatomic, strong) CustomLabel  * contentLabel;
//线view
@property (nonatomic, strong) UIView       * lineView;
//圈子名称
@property (nonatomic, strong) CustomButton * circleBtn;
//地址按钮
@property (nonatomic, strong) CustomButton * locationBtn;
//操作板view
@property (nonatomic, strong) UIView       * operateView;
//评论按钮
@property (nonatomic, strong) CustomButton * commentBtn;
//点赞按钮
@property (nonatomic, strong) CustomButton * likeBtn;

//可变视图数组 比如评论 图片
@property (nonatomic, strong) NSMutableArray * viewArr;

@end

@implementation NewsListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.viewArr                       = [[NSMutableArray alloc] init];
        //头像
        self.headImageBtn                  = [[CustomButton alloc] init];
        //姓名
        self.nameLabel                     = [[CustomLabel alloc] init];
        //时间
        self.timeLabel                     = [[CustomLabel alloc] init];
        //学校
        self.jobBtn                        = [[CustomButton alloc] init];
        //内容
        self.contentLabel                  = [[CustomLabel alloc] init];
        //地址
        self.locationBtn                   = [[CustomButton alloc] init];
        //点赞评论背景
        self.operateView                   = [[UIView alloc] init];
        //评论
        self.commentBtn                    = [[CustomButton alloc] init];
        //点赞
        self.likeBtn                       = [[CustomButton alloc] init];
        self.circleBtn                     = [[CustomButton alloc] init];
        //线
        self.lineView                      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.headImageBtn];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.jobBtn];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.locationBtn];
        [self.contentView addSubview:self.circleBtn];
        [self.contentView addSubview:self.operateView];
        [self.operateView addSubview:self.commentBtn];
        [self.operateView addSubview:self.likeBtn];
        [self.operateView addSubview:self.lineView];
        
        //头像点击
        [self.headImageBtn addTarget:self action:@selector(headClick:) forControlEvents:UIControlEventTouchUpInside];
        //评论
        [self.commentBtn addTarget:self action:@selector(sendCommentClick) forControlEvents:UIControlEventTouchUpInside];
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
    self.selectionStyle                      = UITableViewCellSelectionStyleNone;
    
    //头像
    self.headImageBtn.frame                  = CGRectMake(10, 20, 45, 45);
    self.headImageBtn.layer.cornerRadius     = 2;
    self.headImageBtn.layer.masksToBounds    = YES;
    //姓名
    self.nameLabel.frame                     = CGRectMake(self.headImageBtn.right+15, self.headImageBtn.y+2.5, 200, 16);
    self.nameLabel.font                      = [UIFont systemFontOfSize:FontListName];
    self.nameLabel.textColor                 = [UIColor colorWithHexString:ColorDeepBlack];
    //职位
    self.jobBtn.frame                      = CGRectMake(self.nameLabel.x, self.nameLabel.bottom+10, [DeviceManager getDeviceWidth]-self.nameLabel.x-10, 14);
    self.jobBtn.titleLabel.font            = [UIFont systemFontOfSize:14];
    self.jobBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.jobBtn setTitleColor:[UIColor colorWithHexString:ColorLightBlack] forState:UIControlStateNormal];
    //内容
    self.contentLabel.frame                  = CGRectMake(self.nameLabel.x, self.headImageBtn.bottom+20, [DeviceManager getDeviceWidth]-self.nameLabel.x-10, 0);
    self.contentLabel.userInteractionEnabled = YES;
    self.contentLabel.numberOfLines          = 2;
    self.contentLabel.font                   = [UIFont systemFontOfSize:FontListContent];
    self.contentLabel.textColor              = [UIColor colorWithHexString:ColorDeepBlack];
    //时间
    self.timeLabel.frame                  = CGRectMake(self.nameLabel.x, 0, 100, 12);
    self.timeLabel.font                   = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor              = [UIColor colorWithHexString:ColorLightBlack];
    
    //圈子
    [self.circleBtn setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
    self.circleBtn.titleLabel.font            = [UIFont systemFontOfSize:12];
    self.circleBtn.frame                      = CGRectMake(self.nameLabel.x, 0, 190, 12);
    self.circleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    //地理位置
    [self.locationBtn setTitleColor:[UIColor colorWithHexString:ColorLightBlue] forState:UIControlStateNormal];
    [self.locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    self.locationBtn.titleLabel.font            = [UIFont systemFontOfSize:12];
    self.locationBtn.frame                      = CGRectMake(self.nameLabel.x, 0, 190, 12);
    self.locationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    
    //操作背景
    self.operateView.frame          = CGRectMake(0, 0, [DeviceManager getDeviceWidth], 30);
    self.commentBtn.frame           = CGRectMake(0, 0, [DeviceManager getDeviceWidth]/2, 30);
    self.likeBtn.frame              = CGRectMake([DeviceManager getDeviceWidth]/2, 0, [DeviceManager getDeviceWidth]/2, 30);

    //评论按钮
    self.commentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.commentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);

    //点赞
    self.likeBtn.titleLabel.font    = [UIFont systemFontOfSize:12];
    self.likeBtn.titleEdgeInsets    = UIEdgeInsetsMake(0, 15, 0, 0);
    
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"btn_comment_normal"] forState:UIControlStateNormal];
    [self.commentBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"btn_like_normal"] forState:UIControlStateNormal];
    [self.likeBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateNormal];
    
    //顶部
    UIView * topLineView        = [[UIView alloc] init];
    topLineView.backgroundColor = [UIColor colorWithHexString:ColorSeparator];
    topLineView.frame           = CGRectMake(0, 0, [DeviceManager getDeviceWidth], 1);
    [self.operateView addSubview:topLineView];
    //中间
    UIView * midLineView        = [[UIView alloc] init];
    midLineView.backgroundColor = [UIColor colorWithHexString:ColorSeparator];
    midLineView.frame           = CGRectMake([DeviceManager getDeviceWidth]/2-1, 5, 1, 20);
    [self.operateView addSubview:midLineView];
    //底部线
    self.lineView.backgroundColor = [UIColor colorWithHexString:ColorSeparator];
    self.lineView.frame           = CGRectMake(0, 29, [DeviceManager getDeviceWidth], 1);

}

/*! 内容填充*/
- (void)setConentWithModel:(NewsModel *)news
{
    self.news = news;
    
    //清空可变数组
    [self.viewArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.viewArr removeAllObjects];
    
    //头像
    //加载头像
    NSURL * headUrl          = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, news.head_sub_image]];
    [self.headImageBtn sd_setBackgroundImageWithURL:headUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
    
    //姓名
    NSString * name          = [ToolsManager emptyReturnNone:news.name];
    self.nameLabel.text      = name;

    //学校
    [self.jobBtn setTitle:[NSString stringWithFormat:@"%@ | %@", [ToolsManager emptyReturnNone:news.job], [ToolsManager emptyReturnNone:news.company]] forState:UIControlStateNormal];

    //内容
    CGSize contentSize       = [ToolsManager getSizeWithContent:news.content_text andFontSize:FontListContent andFrame:CGRectMake(0, 0, self.contentLabel.width, MAXFLOAT)];
    //内容长度计算
    if (news.content_text == nil || news.content_text.length < 1) {
        self.contentLabel.height = 0;
    }else if (contentSize.height < 20) {
        //单行
        self.contentLabel.height = 18;
    }else if (contentSize.height > 20) {
        //双行
        self.contentLabel.height = 36;
    }
    self.contentLabel.text   = news.content_text;

    //底部位置
    CGFloat bottomPosition = self.headImageBtn.bottom;
    //内容有的时候
    if (self.contentLabel.height > 0) {
        //底部位置
        bottomPosition = self.contentLabel.bottom;
    }

    //图片处理
    if (news.image_arr.count == 1) {
        //一张图片放大
        ImageModel * imageModel          = news.image_arr[0];
        CGRect rect                      = [NewsUtils getRectWithSize:CGSizeMake(imageModel.width, imageModel.height)];
        rect.origin.x                    = self.nameLabel.x;
        rect.origin.y                    = bottomPosition + 15;
        CustomImageView * imageView      = [[CustomImageView alloc] init];
        //加载单张
        NSURL * imageUrl                 = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, imageModel.sub_url]];
        UITapGestureRecognizer * tap     = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDetailClick:)];
        [imageView addGestureRecognizer:tap];
        [imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"loading_default"]];
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
            CGFloat itemWidth                = ([DeviceManager getDeviceWidth]-self.nameLabel.x-30) / 3;
            imageView.frame                  = CGRectMake(self.nameLabel.x+(itemWidth+10)*columnNum, bottomPosition+(itemWidth+10)*lineNum+15, itemWidth, itemWidth);
            //加载缩略图
            NSURL * imageUrl                 = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, imageModel.sub_url]];
            UITapGestureRecognizer * tap     = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDetailClick:)];
            [imageView addGestureRecognizer:tap];
            [imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"loading_default"]];
            
            [self.contentView addSubview:imageView];
            //底部位置
            if (btnArr.count == i+1) {
                bottomPosition          = imageView.bottom;
            }
            //插入
            [self.viewArr addObject:imageView];
        }
    }
    
    //时间
    NSString * timeStr       = [ToolsManager compareCurrentTime:news.publish_date];
    //算长度
    CGSize lengthSize        = [ToolsManager getSizeWithContent:timeStr andFontSize:13 andFrame:CGRectMake(0, 0, 200, 30)];
    self.timeLabel.width     = lengthSize.width;
    self.timeLabel.y         = bottomPosition+15;
    self.timeLabel.text      = timeStr;
    bottomPosition           = self.timeLabel.bottom;
    
    //圈子按钮 没有不显示
    if (news.circle_arr.count > 0) {
        NSMutableAttributedString * circleTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", KHClubString(@"News_NewsList_CircleFrom"), [news.circle_arr componentsJoinedByString:@","]]];
        self.circleBtn.y       = bottomPosition+10;
        bottomPosition         = self.circleBtn.bottom;
        self.circleBtn.hidden  = NO;
        [circleTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"dfb574"] range:NSMakeRange([KHClubString(@"News_NewsList_CircleFrom") length], circleTitle.length)];
        [self.circleBtn setAttributedTitle:circleTitle forState:UIControlStateNormal];
        
    }else{
        self.circleBtn.hidden = YES;
    }
    
    //地址按钮 没有不显示
    if (news.location.length > 0) {
        NSString * locationTitle                  = [NSString stringWithFormat:@"%@", news.location];
        [self.locationBtn setTitle:locationTitle forState:UIControlStateNormal];
        self.locationBtn.y                        = bottomPosition+10;
        bottomPosition                            = self.locationBtn.bottom;
        self.locationBtn.hidden = NO;
    }else{
        self.locationBtn.hidden = YES;
    }
    
    //评论按钮
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%ld", news.comment_quantity] forState:UIControlStateNormal];
    [self.commentBtn setImage:[UIImage imageNamed:@"comment_btn_normal"] forState:UIControlStateNormal];
    
    //点赞按钮
    if (self.news.is_like) {
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
    }
    [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", news.like_quantity] forState:UIControlStateNormal];
    
    //操作板位置
    self.operateView.y = bottomPosition+15;
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
//发送评论按钮点击
- (void)sendCommentClick {
    
    if ([self.delegate respondsToSelector:@selector(sendCommentClick:)]) {
        [self.delegate sendCommentClick:self.news];
    }
}

//点赞或者取消赞点击
- (void)sendLikeClick {
    
    if ([self.delegate respondsToSelector:@selector(likeClick:likeOrCancel:)]) {
        BOOL likeOrCancel = YES;
        //先修改在进行网络请求
        if (self.news.is_like) {
            self.news.is_like = NO;
            likeOrCancel     = NO;
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

//评论点击
- (void)commentTap:(UITapGestureRecognizer *)tap
{
//    NewsDetailViewController * ndvc = [[NewsDetailViewController alloc] init];
//    ndvc.newsId                     = self.news.nid;
//    [((BaseViewController *)self.delegate) pushVC:ndvc];
}

//浏览其他人的主页
- (void)browsePersonalHome:(NSInteger)userId
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    opvc.uid = userId;
    [((BaseViewController *)self.delegate) pushVC:opvc];
    
}


//- (void)awakeFromNib {
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
