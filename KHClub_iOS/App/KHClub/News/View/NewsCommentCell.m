//
//  NewsCommentCell.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/19.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "NewsCommentCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "OtherPersonalViewController.h"

@interface NewsCommentCell()

//评论模型
@property (nonatomic, strong) CommentModel * comment;
//头像
@property (nonatomic, strong) CustomImageView * headImageView;
//姓名
@property (nonatomic, strong) CustomLabel * nameLabel;
//职位
@property (nonatomic, strong) CustomLabel * jobLabel;
//时间
@property (nonatomic, strong) CustomLabel * timeLabel;
//内容
@property (nonatomic, strong) CustomLabel * contentLabel;
//线
@property (nonatomic, strong) UIView * lineView;
//可变view数组
@property (nonatomic, strong) NSMutableArray * viewArr;

@end

@implementation NewsCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:ColorWhite];
        
        self.viewArr       = [[NSMutableArray alloc] init];
        self.headImageView = [[CustomImageView alloc] init];
        self.nameLabel     = [[CustomLabel alloc] init];
        self.jobLabel      = [[CustomLabel alloc] init];
        self.timeLabel     = [[CustomLabel alloc] init];
        self.contentLabel  = [[CustomLabel alloc] init];
        self.lineView      = [[UIView alloc] init];
        
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.jobLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.lineView];
        
        UITapGestureRecognizer * headTap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewTap:)];
        [self.headImageView addGestureRecognizer:headTap];
        
        //删除或者其他动作
        UITapGestureRecognizer * tap             = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTap:)];
        [self.contentView addGestureRecognizer:tap];
        
        [self configUI];
    }
    
    return self;
}

- (void)configUI
{
    self.selectionStyle                       = UITableViewCellSelectionStyleNone;
    //头像
    self.headImageView.frame                  = CGRectMake(10, 10, 35, 35);
    self.headImageView.layer.cornerRadius     = 2;
    self.headImageView.layer.masksToBounds    = YES;
    self.headImageView.userInteractionEnabled = YES;
    //姓名
    self.nameLabel.frame                      = CGRectMake(self.headImageView.right+10, self.headImageView.y, 150, 20);
    self.nameLabel.textColor                  = [UIColor colorWithHexString:ColorDeepBlack];
    self.nameLabel.font                       = [UIFont systemFontOfSize:FontComment];
    //职位
    self.jobLabel.frame                       = CGRectMake(self.headImageView.right+10, self.nameLabel.bottom, 150, 20);
    self.jobLabel.textColor                   = [UIColor colorWithHexString:ColorLightBlack];
    self.jobLabel.font                        = [UIFont systemFontOfSize:FontComment-2];
    //时间
    self.timeLabel.frame                      = CGRectMake([DeviceManager getDeviceWidth]-120, self.nameLabel.y, 100, 20);
    self.timeLabel.textAlignment              = NSTextAlignmentRight;
    self.timeLabel.font                       = [UIFont systemFontOfSize:11];
    self.timeLabel.textColor                  = [UIColor colorWithHexString:ColorLightBlack];
    //内容
    self.contentLabel.frame                   = CGRectMake(self.nameLabel.x, self.jobLabel.bottom, [DeviceManager getDeviceWidth]-15-self.nameLabel.x, 0);
    self.contentLabel.textColor               = [UIColor colorWithHexString:ColorDeepBlack];
    self.contentLabel.font                    = [UIFont systemFontOfSize:FontComment];
    self.contentLabel.userInteractionEnabled  = YES;
    self.contentLabel.numberOfLines           = 0;
    self.contentLabel.lineBreakMode           = NSLineBreakByCharWrapping;
 
    self.lineView.frame = CGRectMake(0, 0, [DeviceManager getDeviceWidth], 1);
    self.lineView.backgroundColor = [UIColor colorWithHexString:ColorLightGary];
}

- (void)setContentWithModel:(CommentModel *)comment
{
    [self.viewArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.viewArr removeAllObjects];
    
    self.comment        = comment;
    
    //加载头像
    NSURL * headUrl                          = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, comment.head_sub_image]];
    [self.headImageView sd_setImageWithURL:headUrl placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];

    //姓名
    self.nameLabel.text                      = [ToolsManager emptyReturnNone:comment.name];
    //职位
    self.jobLabel.text                       = comment.job;
    //时间
    NSString * timeStr                       = [ToolsManager compareCurrentTime:comment.add_date];
    self.timeLabel.text                      = timeStr;
    //内容
    NSMutableAttributedString * content = [[NSMutableAttributedString alloc] initWithString:comment.comment_content];
    //如果是回复别人
    if (comment.target_id > 0) {
        
        NSString * reply = KHClubString(@"News_NewsDetail_Reply");
        content          = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@：%@", reply, [ToolsManager emptyReturnNone:comment.target_name], comment.comment_content]];
        [content addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:ColorBlue] range:NSMakeRange(reply.length, [ToolsManager emptyReturnNone:comment.target_name].length)];
    }
    CGSize contentSize                       = [ToolsManager getSizeWithContent:content.string andFontSize:FontComment andFrame:CGRectMake(0, 0, [DeviceManager getDeviceWidth]-15-self.nameLabel.x, MAXFLOAT)];
    self.contentLabel.height                 = contentSize.height;
    self.contentLabel.attributedText                   = content;
    

    CGFloat bottomLocation = self.contentLabel.bottom;
    
    if (bottomLocation < 45) {
        bottomLocation = 45;
    }
    
    self.lineView.y = bottomLocation+4;
}

#pragma mark- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    //删除
    if (buttonIndex == 0) {
        [self deleteComment];
    }
    
}

#pragma mark- method response
//头像点击
- (void)headImageViewTap:(UITapGestureRecognizer *)tap
{
    [self browsePersonalHome:self.comment.user_id];
}

//一级评论点击
- (void)commentTap:(UITapGestureRecognizer *)tap
{
    if (self.comment.user_id == [UserService sharedService].user.uid) {
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:StringCommonPrompt delegate:self cancelButtonTitle:StringCommonCancel destructiveButtonTitle:nil otherButtonTitles:KHClubString(@"Common_Delete"), nil];
        sheet.tag             = tap.view.tag;
        [sheet showInView:[(UIViewController *)self.delegate view]];
    }else{
        [self replyComment];
    }
}

- (void)replyComment
{
    //回复别人
    if ([self.delegate respondsToSelector:@selector(replyComment:)]) {
        
        [self.delegate replyComment:self.comment];
    }
}

#pragma mark- private method
- (void)deleteComment
{
    if ([self.delegate respondsToSelector:@selector(deleteCommentClick:)]) {
        [self.delegate deleteCommentClick:self.comment];
    }
}

//浏览其他人的主页
- (void)browsePersonalHome:(NSInteger)userId
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    opvc.uid = userId;
    [((BaseViewController *)self.delegate) pushVC:opvc];
    
}

#pragma mark- private method
- (void)commentLabelSet:(UILabel *)label
{
    label.lineBreakMode          = NSLineBreakByCharWrapping;
    label.userInteractionEnabled = YES;
    label.font                   = [UIFont systemFontOfSize:FontComment];
    label.textColor              = [UIColor colorWithHexString:ColorLightBlack];
}

@end
