//
//  CircleNoticeCell.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleNoticeCell.h"
#import "CommentModel.h"
#import "LikeModel.h"

@interface CircleNoticeCell()

//公告
@property (nonatomic, strong) CircleNoticeModel * notice;
//时间
@property (nonatomic, strong) CustomLabel       * timeLabel;
//内容
@property (nonatomic, strong) CustomLabel       * contentLabel;
//线view
@property (nonatomic, strong) UIView            * lineView;
//操作板view
@property (nonatomic, strong) UIView            * operateView;
//评论按钮
@property (nonatomic, strong) CustomButton      * commentBtn;
//点赞按钮
@property (nonatomic, strong) CustomButton      * likeBtn;

@end

@implementation CircleNoticeCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //时间
        self.timeLabel                     = [[CustomLabel alloc] init];
        //内容
        self.contentLabel                  = [[CustomLabel alloc] init];
        //点赞评论背景
        self.operateView                   = [[UIView alloc] init];
        //评论
        self.commentBtn                    = [[CustomButton alloc] init];
        //点赞
        self.likeBtn                       = [[CustomButton alloc] init];
        //线
        self.lineView                      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.operateView];
        [self.operateView addSubview:self.commentBtn];
        [self.operateView addSubview:self.likeBtn];
        [self.operateView addSubview:self.lineView];
        
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
    self.selectionStyle                    = UITableViewCellSelectionStyleNone;

    //内容
    self.contentLabel.frame                  = CGRectMake(10, 10, [DeviceManager getDeviceWidth]-20, 0);
    self.contentLabel.userInteractionEnabled = YES;
    self.contentLabel.numberOfLines          = 2;
    self.contentLabel.font                   = [UIFont systemFontOfSize:FontListContent];
    self.contentLabel.textColor              = [UIColor colorWithHexString:ColorDeepBlack];
    self.contentLabel.lineBreakMode          = NSLineBreakByCharWrapping;
    //时间
    self.timeLabel.frame                  = CGRectMake(self.contentLabel.x, 0, 200, 12);
    self.timeLabel.font                   = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor              = [UIColor colorWithHexString:ColorLightBlack];
    //操作背景
    self.operateView.frame          = CGRectMake(0, 0, [DeviceManager getDeviceWidth], 30);
    self.commentBtn.frame           = CGRectMake(0, 0, [DeviceManager getDeviceWidth]/2, 30);
    self.commentBtn.enabled         = NO;
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
- (void)setContentWithModel:(CircleNoticeModel *)notice
{
    self.notice                    = notice;
    
    //特殊处理文字
    NSMutableParagraphStyle * para = [[NSMutableParagraphStyle alloc] init];
    para.lineBreakMode             = NSLineBreakByCharWrapping;
    para.lineSpacing               = 10;
    NSDictionary * dic             = @{NSFontAttributeName : [UIFont systemFontOfSize:FontListContent],
                                       NSParagraphStyleAttributeName : para};
    CGRect rect                                  = [self.notice.content_text boundingRectWithSize:CGSizeMake(self.contentLabel.width, 45) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    self.contentLabel.height                     = rect.size.height;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:notice.content_text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, [notice.content_text length])];
    self.contentLabel.attributedText             = attributedString;

    //底部位置
    CGFloat bottomPosition = self.contentLabel.bottom;
    
    //时间
    NSString * timeStr       = [ToolsManager compareCurrentTime:notice.publish_date];
    //算长度
    self.timeLabel.y         = bottomPosition+15;
    self.timeLabel.text      = timeStr;
    bottomPosition           = self.timeLabel.bottom;
    
    //评论按钮
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%ld", notice.comment_quantity] forState:UIControlStateNormal];
    [self.commentBtn setImage:[UIImage imageNamed:@"comment_btn_normal"] forState:UIControlStateNormal];
    
    //点赞按钮
    if (notice.is_like) {
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
    }
    [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", notice.like_quantity] forState:UIControlStateNormal];
    
    //操作板位置
    self.operateView.y = bottomPosition+15;
    
}

#pragma mark- method response

//长按复制
- (void)longPressCopy:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(longPressContent:andGes:)]) {
            [self.delegate longPressContent:self.notice andGes:longPress];
        }
    }
    
}

//复制
- (void)copyContnet:(id)sender
{
    //得到剪切板
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string        = self.notice.content_text;
    debugLog(@"%@",[UIPasteboard generalPasteboard].string);
}
//取消menu
- (void)cancel:(id)sender
{}

//发送评论按钮点击
- (void)sendCommentClick {
    
    if ([self.delegate respondsToSelector:@selector(sendCommentClick:)]) {
        [self.delegate sendCommentClick:self.notice];
    }
}

//点赞或者取消赞点击
- (void)sendLikeClick {
    
    if ([self.delegate respondsToSelector:@selector(likeClick:likeOrCancel:)]) {
        BOOL likeOrCancel = YES;
        //先修改在进行网络请求
        if (self.notice.is_like) {
            self.notice.is_like = NO;
            likeOrCancel        = NO;
            self.notice.like_quantity --;
            [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"btn_like_normal"] forState:UIControlStateNormal];
            [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
        }else{
            self.notice.is_like = YES;
            self.notice.like_quantity ++;
            [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
        }
        [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", self.notice.like_quantity] forState:UIControlStateNormal];
        [self.delegate likeClick:self.notice likeOrCancel:likeOrCancel];
    }
    
    
}

@end
