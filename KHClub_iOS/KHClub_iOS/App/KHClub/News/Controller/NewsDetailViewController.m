//
//  NewsDetailViewController.m
//  JLXCSNS_iOS
//
//  Created by 李晓航 on 15/5/18.
//  Copyright (c) 2015年 JLXC. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "BrowseImageListViewController.h"
#import "LikeModel.h"
#import "LikeListCell.h"
#import "CommentModel.h"
#import "ImageModel.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "BrowseImageViewController.h"
#import "NewsCommentCell.h"
#import "HPGrowingTextView.h"
#import "OtherPersonalViewController.h"
#import "NewsUtils.h"

@interface NewsDetailViewController ()<NewsCommentDelegate,HPGrowingTextViewDelegate>

//头像
@property (nonatomic, strong) CustomImageView   * headImageView;
//姓名
@property (nonatomic, strong) CustomLabel       * nameLabel;
//时间
@property (nonatomic, strong) CustomLabel       * timeLabel;
//职位 | 公司
@property (nonatomic, strong) CustomLabel       * jobLabel;
//内容
@property (nonatomic, strong) CustomLabel       * contentLabel;
//地址按钮
@property (nonatomic, strong) CustomButton      * locationBtn;
//点赞按钮
@property (nonatomic, strong) CustomButton      * likeBtn;
//点赞数量按钮
@property (nonatomic, strong) CustomButton      * likeCountBtn;
//评论数量按钮
@property (nonatomic, strong) CustomButton      * commentCountBtn;
//圈子名称
@property (nonatomic, strong) CustomButton      * circleBtn;
//评论table
@property (nonatomic, strong) UITableView       * newsTable;
//装载HPTextView的容器
@property (nonatomic, strong) UIView            * containerView;
//HPTextView 回复评论时弹出
@property (nonatomic, strong) HPGrowingTextView * commentTextView;
//当前点击的最上级评论
@property (nonatomic, strong) CommentModel      * currentTopComment;
//评论遮罩View
@property (nonatomic, strong) UIView            * commentCoverView;
//发送评论按钮
@property (nonatomic, strong) CustomButton      * sendCommentBtn;

//新闻模型
@property (nonatomic, strong) NewsModel         * news;

//当前是点赞列表 还是 评论列表
@property (nonatomic, assign) BOOL              isLikeOrComment;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];
    [self registerNotify];
    [self initWidget];
    [self configUI];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- layout
- (void)initWidget
{
    //内容scroll
    //头像
    self.headImageView              = [[CustomImageView alloc] init];
    //姓名
    self.nameLabel                  = [[CustomLabel alloc] init];
    //时间
    self.timeLabel                  = [[CustomLabel alloc] init];
    //学校
    self.jobLabel                   = [[CustomLabel alloc] init];
    //内容
    self.contentLabel               = [[CustomLabel alloc] init];
    //地址
    self.locationBtn                = [[CustomButton alloc] init];
    //点赞
    self.likeBtn                    = [[CustomButton alloc] init];
    //点赞数量
    self.likeCountBtn               = [[CustomButton alloc] init];
    //评论数量
    self.commentCountBtn            = [[CustomButton alloc] init];
    self.circleBtn                  = [[CustomButton alloc] init];
    
    UITapGestureRecognizer * tap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newsHeadClick:)];
    [self.headImageView addGestureRecognizer:tap];
    
    [self.likeBtn addTarget:self action:@selector(sendLikeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.commentCountBtn addTarget:self action:@selector(choiceCommentList:) forControlEvents:UIControlEventTouchUpInside];
    [self.likeCountBtn addTarget:self action:@selector(choiceLikeList:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"News_NewsDetail_Tilte")];
    //头像
    self.headImageView.frame                  = CGRectMake(12, 10, 45, 45);
    self.headImageView.layer.cornerRadius     = 2;
    self.headImageView.layer.masksToBounds    = YES;
    self.headImageView.userInteractionEnabled = YES;
    
    //姓名
    self.nameLabel.font                   = [UIFont systemFontOfSize:FontListName];
    self.nameLabel.textColor              = [UIColor colorWithHexString:ColorDeepBlack];
    //学校
    self.jobLabel.font                    = [UIFont systemFontOfSize:13];
    self.jobLabel.textColor               = [UIColor colorWithHexString:ColorLightBlack];
    
    self.contentLabel.frame               = CGRectMake(self.headImageView.x, self.headImageView.bottom+5, [DeviceManager getDeviceWidth]-30, 0);
    self.contentLabel.numberOfLines       = 0;
    self.contentLabel.font                = [UIFont systemFontOfSize:15];
    self.contentLabel.textColor           = [UIColor colorWithHexString:ColorDeepBlack];
    
    //圈子
    [self.circleBtn setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
    self.circleBtn.titleLabel.font            = [UIFont systemFontOfSize:12];
    self.circleBtn.frame                      = CGRectMake(self.headImageView.x, 0, self.viewWidth-self.headImageView.x-10, 20);
    self.circleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.circleBtn.titleLabel.numberOfLines   = 0;
    //地理位置
    [self.locationBtn setTitleColor:[UIColor colorWithHexString:ColorLightBlue] forState:UIControlStateNormal];
    [self.locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    self.locationBtn.titleLabel.font            = [UIFont systemFontOfSize:12];
    self.locationBtn.frame                      = CGRectMake(self.headImageView.x, 0, 190, 20);
    self.locationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //时间
    self.timeLabel.frame                        = CGRectMake(self.headImageView.x, 0, 250, 20);
    self.timeLabel.font                         = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor                    = [UIColor colorWithHexString:ColorLightBlack];

    //点赞
    self.likeBtn.titleLabel.font                = [UIFont systemFontOfSize:14];
    self.likeBtn.titleEdgeInsets                = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"btn_like_normal"] forState:UIControlStateNormal];

    //评论数量
    self.commentCountBtn.titleLabel.font            = [UIFont systemFontOfSize:12];
    self.commentCountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.commentCountBtn.selected                   = YES;
    [self.commentCountBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateSelected];
    [self.commentCountBtn setTitleColor:[UIColor colorWithHexString:ColorLightBlack] forState:UIControlStateNormal];
    //点赞数量
    self.likeCountBtn.titleLabel.font               = [UIFont systemFontOfSize:12];
    [self.likeCountBtn setTitleColor:[UIColor colorWithHexString:ColorDeepBlack] forState:UIControlStateSelected];
    [self.likeCountBtn setTitleColor:[UIColor colorWithHexString:ColorLightBlack] forState:UIControlStateNormal];

}

- (void)initCommentTextView
{
    
    //评论遮罩
    self.commentCoverView                 = [[UIView alloc] initWithFrame:self.view.bounds];
    self.commentCoverView.backgroundColor = [UIColor colorWithHexString:ColorLightBlack];
    self.commentCoverView.alpha           = 0.3;
    self.commentCoverView.hidden          = YES;
    [self.view addSubview:self.commentCoverView];
    
    //回复评论的textView
    self.containerView                                          = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.viewWidth, 40)];

    self.containerView.backgroundColor                          = [UIColor colorWithHexString:ColorLightGary];
    self.commentTextView                                        = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 4, self.viewWidth-80, 30)];
    self.commentTextView.isScrollable                           = NO;
    self.commentTextView.textColor                              = [UIColor colorWithHexString:ColorDeepBlack];
    self.commentTextView.minNumberOfLines                       = 1;
    self.commentTextView.maxNumberOfLines                       = 6;
    self.commentTextView.returnKeyType                          = UIReturnKeySend;
    self.commentTextView.font                                   = [UIFont systemFontOfSize:13.0f];
    self.commentTextView.delegate                               = self;
    self.commentTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.commentTextView.backgroundColor                        = [UIColor whiteColor];
    self.commentTextView.placeholder                            = KHClubString(@"News_NewsDetail_EnterComment");
    [self.containerView addSubview:self.commentTextView];
    [self.view addSubview:self.containerView];
    //发送按钮
    self.sendCommentBtn = [[CustomButton alloc] initWithFrame:CGRectMake(self.commentTextView.right+5, 4, 60, 32)];
    [self.sendCommentBtn setBackgroundColor:[UIColor colorWithHexString:ColorGold]];
    [self.sendCommentBtn setTitleColor:[UIColor colorWithHexString:ColorBrown] forState:UIControlStateNormal];
    [self.sendCommentBtn addTarget:self action:@selector(sendCommentPress) forControlEvents:UIControlEventTouchUpInside];
    [self.sendCommentBtn setFontSize:13];
    [self.sendCommentBtn setTitle:KHClubString(@"News_Publish_Send") forState:UIControlStateNormal];
    [self.containerView addSubview:self.sendCommentBtn];
  
}

- (void)initTable
{
    //展示数据的列表
    if ([DeviceManager getDeviceSystem] >= 7.0) {
        self.newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight-40) style:UITableViewStyleGrouped];
    }else{
        self.newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight-40) style:UITableViewStylePlain];
    }
    
    self.newsTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.newsTable.backgroundColor = [UIColor colorWithHexString:ColorLightWhite];
    self.newsTable.delegate        = self;
    self.newsTable.dataSource      = self;
    [self.view addSubview:self.newsTable];
    
    //加载回复评论的textView
    [self initCommentTextView];
}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self confirmDelete];
    }
}

#pragma mark- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isLikeOrComment) {
        //点赞的话
        OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
        LikeModel * model                  = self.news.like_arr[indexPath.row];
        opvc.uid                           = model.user_id;
        [self pushVC:opvc];
    }

}
//头部
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self getHeadNewsHeight];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * backView        = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, [self getHeadNewsHeight])];
    backView.backgroundColor = [UIColor colorWithHexString:ColorWhite];
    [backView addSubview:self.headImageView];
    [backView addSubview:self.nameLabel];
    [backView addSubview:self.timeLabel];
    [backView addSubview:self.jobLabel];
    [backView addSubview:self.contentLabel];
    [backView addSubview:self.locationBtn];
    [backView addSubview:self.circleBtn];
    [backView addSubview:self.likeBtn];
    [backView addSubview:self.commentCountBtn];
    [backView addSubview:self.likeCountBtn];
    
    //头像
    NSURL * headUrl                           = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, self.news.head_sub_image]];
    [self.headImageView sd_setImageWithURL:headUrl placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];

    //姓名
    NSString * name              = [ToolsManager emptyReturnNone:self.news.name];
    CGSize nameSize              = [ToolsManager getSizeWithContent:name andFontSize:FontListName andFrame:CGRectMake(0, 0, 200, 20)];
    self.nameLabel.frame         = CGRectMake(self.headImageView.right+10, self.headImageView.y, nameSize.width, 20);
    self.nameLabel.text          = name;
    
    //学校
    self.jobLabel.frame          = CGRectMake(self.nameLabel.x, self.nameLabel.bottom, 250, 20);
    self.jobLabel.text           = [NSString stringWithFormat:@"%@ | %@", [ToolsManager emptyReturnNone:self.news.job], [ToolsManager emptyReturnNone:self.news.company]];
    //内容
    CGSize contentSize       = [ToolsManager getSizeWithContent:self.news.content_text andFontSize:15 andFrame:CGRectMake(0, 0, [DeviceManager getDeviceWidth]-30, MAXFLOAT)];
    if (self.news.content_text == nil || self.news.content_text.length < 1) {
        contentSize.height   = 0;
    }
    self.contentLabel.height = contentSize.height;
    self.contentLabel.text   = self.news.content_text;
    
    //底部位置
    CGFloat bottomPosition = self.contentLabel.bottom ;
    //图片处理
    if (self.news.image_arr.count == 1) {
        //一张图片放大
        ImageModel * imageModel      = self.news.image_arr[0];
        CGRect rect                  = [NewsUtils getRectWithSize:CGSizeMake(imageModel.width, imageModel.height)];
        rect.origin.x                = self.headImageView.x;
        rect.origin.y                = self.contentLabel.bottom+5;
        CustomButton * imageBtn      = [[CustomButton alloc] init];
        //加载单张
        NSURL * imageUrl             = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, imageModel.sub_url]];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDetailClick:)];
        imageBtn.frame               = rect;
        //底部位置
        bottomPosition               = imageBtn.bottom;
        
        [imageBtn addGestureRecognizer:tap];
        [imageBtn sd_setBackgroundImageWithURL:imageUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"loading_default"]];
        [backView addSubview:imageBtn];
    }else{
        //多张图片九宫格
        NSArray * btnArr        = self.news.image_arr;
        for (int i=0; i<btnArr.count; i++) {
            ImageModel * imageModel          = self.news.image_arr[i];
            NSInteger columnNum              = i%3;
            NSInteger lineNum                = i/3;
            CustomImageView * imageView      = [[CustomImageView alloc] init];
            imageView.tag                    = i;
            imageView.userInteractionEnabled = YES;
            imageView.contentMode            = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds    = YES;
            CGFloat itemWidth                = [DeviceManager getDeviceWidth]/5.0;
            imageView.frame                  = CGRectMake(self.headImageView.x+(itemWidth+10)*columnNum, self.contentLabel.bottom+5+(itemWidth+10)*lineNum, itemWidth, itemWidth);
            //加载缩略图
            NSURL * imageUrl                 = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAttachmentAddr, imageModel.sub_url]];
            UITapGestureRecognizer * tap     = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDetailClick:)];
            
            [imageView addGestureRecognizer:tap];
            [imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"loading_default"]];
            [backView addSubview:imageView];
            //底部位置
            if (btnArr.count == i+1) {
                bottomPosition          = imageView.bottom;
            }
        }
    }

    //圈子部分 没有不显示
    if (self.news.circle_arr.count > 0) {
        //字符串拼接
        NSMutableAttributedString * circleTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@", KHClubString(@"News_NewsList_CircleFrom"), [self.news.circle_arr componentsJoinedByString:@","]]];
        //大小计算
        CGSize circleSize      = [ToolsManager getSizeWithContent:circleTitle.string andFontSize:12 andFrame:CGRectMake(0, 0, self.circleBtn.width, MAXFLOAT)];
        if (circleSize.height > 20) {
            self.circleBtn.height  = circleSize.height;
        }
        [circleTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"dfb574"] range:NSMakeRange([KHClubString(@"News_NewsList_CircleFrom") length]+1, circleTitle.length-[KHClubString(@"News_NewsList_CircleFrom") length]-1)];
        [self.circleBtn setAttributedTitle:circleTitle forState:UIControlStateNormal];
        //位置
        self.circleBtn.y       = bottomPosition+5;
        self.circleBtn.hidden  = NO;
        bottomPosition         = self.circleBtn.bottom;
        
    }else{
        self.circleBtn.hidden = YES;
    }
    //地址按钮 没有不显示
    if (self.news.location.length > 0) {
        NSString * locationTitle                  = [NSString stringWithFormat:@" %@", self.news.location];
        [self.locationBtn setTitle:locationTitle forState:UIControlStateNormal];
        self.locationBtn.y                        = bottomPosition+5;
        bottomPosition                            = self.locationBtn.bottom;
    }else{
        self.locationBtn.hidden = YES;
    }
    
    //时间
    NSString * timeStr       = [ToolsManager compareCurrentTime:self.news.publish_date];
    self.timeLabel.y         = bottomPosition+5;
    self.timeLabel.text      = timeStr;
    
    //点赞按钮
    self.likeBtn.frame      = CGRectMake([DeviceManager getDeviceWidth]-65, bottomPosition, 60, 25);
    if (self.news.is_like) {
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
    }
    
    bottomPosition           = self.likeBtn.bottom;
    //线
    UIView * lineView        = [[UIView alloc] initWithFrame:CGRectMake(0, bottomPosition+10, self.viewWidth, 10)];
    lineView.backgroundColor = [UIColor colorWithHexString:ColorLightGary];
    [backView addSubview:lineView];
    
    bottomPosition = lineView.bottom;
    
    //评论
    self.commentCountBtn.frame = CGRectMake(self.timeLabel.x, bottomPosition, 80, 40);
    [self.commentCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Comment"),self.news.comment_quantity] forState:UIControlStateNormal];
    
    //点赞
    self.likeCountBtn.frame = CGRectMake(self.viewWidth-60, bottomPosition, 50, 40);
    [self.likeCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Like"), self.news.like_quantity] forState:UIControlStateNormal];
    
    //点赞头像 最多3个 大小根据分辨率算
    NSInteger likeCout = self.news.like_arr.count;
    if (likeCout > 3) {
        likeCout = 3;
    }
    for (int i=0; i<likeCout; i++) {
        
        LikeModel * like           = self.news.like_arr[i];
        CustomButton * likeHeadBtn = [[CustomButton alloc] initWithFrame:CGRectMake(self.likeCountBtn.x - 40*(i+1), bottomPosition+5, 30, 30)];
        NSURL * headUrl            = [NSURL URLWithString:[ToolsManager completeUrlStr:like.head_sub_image]];
        [likeHeadBtn sd_setBackgroundImageWithURL:headUrl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR]];
        likeHeadBtn.tag            = i;
        //点击事件
        [likeHeadBtn addTarget:self action:@selector(likeHeadClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:likeHeadBtn];
    }
    
    //底部线
    UIView * bottomLineView        = [[UIView alloc] initWithFrame:CGRectMake(0, bottomPosition+39, self.viewWidth, 1)];
    bottomLineView.backgroundColor = [UIColor colorWithHexString:ColorLightGary];
    [backView addSubview:bottomLineView];
    return backView;
}

//数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isLikeOrComment) {
        return self.news.like_arr.count;
    }
    return self.news.comment_arr.count;
}

//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果是点赞列表
    if (self.isLikeOrComment) {
        return 60;
    }
    
    CommentModel * comment = self.news.comment_arr[indexPath.row];
    
    NSString * content = comment.comment_content;
    //回复别人的
    if (comment.target_id > 0) {
        NSString * reply = KHClubString(@"News_NewsDetail_Reply");
        content = [NSString stringWithFormat:@"%@%@：%@", reply, [ToolsManager emptyReturnNone:comment.target_name], comment.comment_content];
    }
    
    CGSize contentSize     = [ToolsManager getSizeWithContent:content andFontSize:FontComment andFrame:CGRectMake(0, 0, [DeviceManager getDeviceWidth]-15-55, MAXFLOAT)];
    
    CGFloat total = 50+contentSize.height;
    if (total < 70) {
        total = 70;
    }
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果是点赞列表
    if (self.isLikeOrComment) {
        LikeListCell * cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"likecell%ld", indexPath.row]];
        if (!cell) {
            cell = [[LikeListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"likecell%ld", indexPath.row]];
        }
        [cell setContentWithModel:self.news.like_arr[indexPath.row]];
        return cell;
    }
    
    NewsCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld", indexPath.row]];
    if (!cell) {
        cell = [[NewsCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell%ld", indexPath.row]];
        cell.delegate = self;
    }
    [cell setContentWithModel:self.news.comment_arr[indexPath.row]];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.commentTextView resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark- HPGrowingTextViewDelegate
-(void) keyboardWillShow:(NSNotification *)note{

    self.commentCoverView.hidden = NO;
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    [UIView animateWithDuration:0.2f animations:^{
        self.containerView.frame = containerFrame;
    }];
    
}

-(void) keyboardWillHide:(NSNotification *)note{

    self.commentCoverView.hidden     = YES;
    self.commentTextView.placeholder = KHClubString(@"News_NewsDetail_EnterComment");
    self.commentTextView.text        = @"";

    //当前回复对象置空
    self.currentTopComment           = nil;
    
    CGRect containerFrame            = self.containerView.frame;
    containerFrame.origin.y          = self.view.bounds.size.height-40;
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.frame = containerFrame;
    }];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff               = (growingTextView.frame.size.height - height);
    CGRect r                 = self.containerView.frame;
    r.size.height            -= diff;
    r.origin.y               += diff;
    self.containerView.frame = r;
    
    self.sendCommentBtn.y    = (self.containerView.height-self.sendCommentBtn.height)/2;
}

//判断发送
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (growingTextView == self.commentTextView) {
        if ([text isEqualToString:@"\n"]) {
            //发送评论
            [self sendCommentPress];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark- NewsCommentDelegate
//删除评论
- (void)deleteCommentClick:(CommentModel *)comment
{
    
    NSDictionary * params = @{@"cid":[NSString stringWithFormat:@"%ld", comment.cid],
                              @"news_id":[NSString stringWithFormat:@"%ld", self.news.nid]};
    debugLog(@"%@ %@", kDeleteCommentPath, params);
    [self showLoading:StringCommonUploadData];
    [HttpService postWithUrlString:kDeleteCommentPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self showComplete:KHClubString(@"News_NewsDetail_DeleteSuccess")];
            //成功之后更新
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.news.comment_arr indexOfObject:comment]inSection:0];
            [self.news.comment_arr removeObject:comment];
            [self.newsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //评论减少
            self.news.comment_quantity--;
            //UI更新
            [self.commentCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Comment"), self.news.comment_quantity] forState:UIControlStateNormal];
            
        }else{
            [self showWarn:KHClubString(@"News_NewsDetail_DeleteFail")];
        }
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

//回复评论
- (void)replyComment:(CommentModel *)comment
{

    self.currentTopComment           = comment;

    self.commentTextView.placeholder = [NSString stringWithFormat:@"%@：%@", KHClubString(@"News_NewsDetail_Reply"), comment.name];
    
    [self.commentTextView becomeFirstResponder];
}

#pragma mark- method response
/**
 *  切换成评论
 *
 *  @param sender
 */
- (void)choiceCommentList:(id)sender
{
    self.isLikeOrComment          = NO;
    self.commentCountBtn.selected = YES;
    self.likeCountBtn.selected    = NO;
    [self.newsTable reloadData];
}
/**
 *  切换成点赞
 *
 *  @param sender
 */
- (void)choiceLikeList:(id)sender
{
    self.isLikeOrComment          = YES;
    self.likeCountBtn.selected    = YES;
    self.commentCountBtn.selected = NO;
    [self.newsTable reloadData];
}

//图片点击
- (void)imageDetailClick:(UITapGestureRecognizer *) ges {

    BrowseImageListViewController * bilvc = [[BrowseImageListViewController alloc] init];
    bilvc.num                             = ges.view.tag;
    bilvc.dataSource                      = self.news.image_arr;
    [self presentViewController:bilvc animated:YES completion:nil];
    
}

//点赞或者取消赞点击
- (void)sendLikeClick {
    
    UserModel * user = [UserService sharedService].user;
    
    BOOL likeOrCancel = YES;
    //先修改在进行网络请求
    if (self.news.is_like) {
        self.news.is_like = NO;
        likeOrCancel     = NO;
        self.news.like_quantity --;
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
        //页面刷新
        for (LikeModel * likeModel in self.news.like_arr) {
            if (likeModel.user_id == user.uid) {
                [self.news.like_arr removeObject:likeModel];
                [self.newsTable reloadData];
                break;
            }
        }
        
    }else{
        self.news.is_like = YES;
        self.news.like_quantity ++;
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
        //界面刷新
        LikeModel * like    = [[LikeModel alloc] init];
        like.user_id        = user.uid;
        like.name           = user.name;
        like.head_image     = user.head_image;
        like.head_sub_image = user.head_sub_image;
        [self.news.like_arr insertObject:like atIndex:0];
        [self.newsTable reloadData];
        
    }
    [self.likeCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Like"), self.news.like_quantity] forState:UIControlStateNormal];
    
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"news_id":[NSString stringWithFormat:@"%ld", self.news.nid],
                              @"isLike":[NSString stringWithFormat:@"%d", likeOrCancel],
                              @"is_second":@"0"};
    debugLog(@"%@ %@", kLikeOrCancelPath, params);
    //成功失败都没反应
    [HttpService postWithUrlString:kLikeOrCancelPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);

    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//tableView手势
- (void)tapTableView:(UITapGestureRecognizer *)ges
{
    [self.commentTextView resignFirstResponder];
}
//点赞头像点击
- (void)likeHeadClick:(CustomButton *)sender
{
    LikeModel * like           = self.news.like_arr[sender.tag];
    [self browsePersonalHome:like.user_id];
}
//新闻头像点击
- (void)newsHeadClick:(UITapGestureRecognizer *)ges
{
    [self browsePersonalHome:self.news.uid];
}

#pragma mark- private method
//发送评论
- (void)sendCommentPress
{
    //如果是默认评论
    [self publishComment];
    [self.commentTextView resignFirstResponder];
    self.commentTextView.text = @"";

}

//浏览其他人的主页
- (void)browsePersonalHome:(NSInteger)userId
{
    OtherPersonalViewController * opvc = [[OtherPersonalViewController alloc] init];
    opvc.uid = userId;
    [self pushVC:opvc];
}

- (void)getData
{
    NSString * url = [NSString stringWithFormat:@"%@?news_id=%ld&user_id=%ld", kNewsDetailPath, self.newsId, [UserService sharedService].user.uid];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            NSDictionary * newsDic = responseData[HttpResult];
            //数据处理
            NewsModel * news = [[NewsModel alloc] init];
            [news setContentWithDic:newsDic];
            
            //如果是自己柯以删除
            if ([UserService sharedService].user.uid == news.uid) {
                self.navBar.rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
                //右上角设置
                __weak typeof(self) weakSelf         = self;
                [self.navBar setRightBtnWithContent:@"" andBlock:^{
                    [weakSelf deleteNewsClick:weakSelf.news];
                }];
                [self.navBar.rightBtn setImage:[UIImage imageNamed:@"delete_btn_normal"] forState:UIControlStateNormal];
                [self.navBar.rightBtn setImage:[UIImage imageNamed:@"delete_btn_normal"] forState:UIControlStateHighlighted];
                self.navBar.rightBtn.hidden = NO;
            }else{
                self.navBar.rightBtn.hidden = YES;
            }
            
            self.news = news;
            [self initTable];
        }else{
            [self showWarn:responseData[HttpMessage]];
            
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {

//        [self showWarn:StringCommonNetException];
    }];
}

//评论
- (void)publishComment
{
    
    if (self.commentTextView.text.length > 100) {
        [self showWarn:KHClubString(@"News_Publish_CotentTooLong")];
        return;
    }
    
    if (self.commentTextView.text.length < 1) {
        [self showWarn:KHClubString(@"News_NewsDetail_ContentEmpty")];
        return;
    }
    
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"comment_content":self.commentTextView.text,
                              @"news_id":[NSString stringWithFormat:@"%ld", self.newsId]};
    if (self.currentTopComment != nil) {
        params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                                  @"comment_content":self.commentTextView.text,
                                  @"news_id":[NSString stringWithFormat:@"%ld", self.newsId],
                                  @"target_id":[NSString stringWithFormat:@"%ld", self.currentTopComment.user_id],
                                  @"target_name":self.currentTopComment.name};
    }
    
    [self showLoading:nil];
    debugLog(@"%@ %@", kSendCommentPath, params);
    [HttpService postWithUrlString:kSendCommentPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self showComplete:KHClubString(@"News_Publish_Success")];
            //生成评论模型
            CommentModel * comment = [[CommentModel alloc] init];
            [comment setContentWithDic:responseData[HttpResult]];
            [self.news.comment_arr addObject:comment];
            comment.name           = [UserService sharedService].user.name;
            comment.head_image     = [UserService sharedService].user.head_image;
            comment.head_sub_image = [UserService sharedService].user.head_sub_image;
            comment.job            = [UserService sharedService].user.job;
            comment.target_id      = [params[@"target_id"] integerValue];
            comment.target_name    = params[@"target_name"];
            
            //评论增加
            self.news.comment_quantity++;
            [self.commentCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Comment"), self.news.comment_quantity] forState:UIControlStateNormal];
            
            //更新table
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.news.comment_arr.count-1 inSection:0];
            [self.newsTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [self.newsTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            
        }else{
            if ([responseData[HttpResult] integerValue] == 1) {
                [self hideLoading];
                [self showHint:KHClubString(@"News_NewsDetail_CircleNoFollow")];
            }else{
                [self showWarn:KHClubString(@"News_Publish_Fail")];
            }

        }
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

/*! 删除该条状态*/
- (void)deleteNewsClick:(NewsModel *)news
{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:KHClubString(@"News_Publish_DeleteConfirm") message:nil delegate:self cancelButtonTitle:StringCommonCancel otherButtonTitles:StringCommonConfirm, nil];
    [alert show];
    
}

//删除动态
- (void)confirmDelete
{
    NSDictionary * params = @{@"news_id":[NSString stringWithFormat:@"%ld", self.news.nid]};
    debugLog(@"%@ %@", kDeleteNewsListPath, params);
    
    [self showLoading:StringCommonUploadData];
    [HttpService postWithUrlString:kDeleteNewsListPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        
        if (status == HttpStatusCodeSuccess) {
            [self showComplete:KHClubString(@"News_NewsDetail_DeleteSuccess")];
            //发送发送成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_PUBLISH_NEWS object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else{

            [self showWarn:KHClubString(@"News_NewsDetail_DeleteFail")];
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showWarn:StringCommonNetException];
    }];
}

- (CGFloat)getHeadNewsHeight
{
    CGSize contentSize        = [ToolsManager getSizeWithContent:self.news.content_text andFontSize:15 andFrame:CGRectMake(0, 0, self.viewWidth-30, MAXFLOAT)];
    if (self.news.content_text == nil || self.news.content_text.length < 1) {
        contentSize.height = 0;
    }
    //头像55 时间25 评论40 还有20的底线
    NSInteger cellOtherHeight = 55+25+40+20;
    
    CGFloat height;
    if (self.news.image_arr.count < 1) {
        //没有图片
        height = cellOtherHeight+contentSize.height+5;
    }else if (self.news.image_arr.count == 1) {
        //一张图片 大图
        ImageModel * imageModel = self.news.image_arr[0];
        CGSize size             = CGSizeMake(imageModel.width, imageModel.height);
        CGRect rect             = [NewsUtils getRectWithSize:size];
        height                  = cellOtherHeight+contentSize.height+rect.size.height+10;
    }else{
        //多张图片九宫格
        NSInteger lineNum   = self.news.image_arr.count/3;
        NSInteger columnNum = self.news.image_arr.count%3;
        if (columnNum > 0) {
            lineNum++;
        }
        CGFloat itemWidth = [DeviceManager getDeviceWidth]/5.0;
        height            = cellOtherHeight+contentSize.height+lineNum*(itemWidth+10);
    }
    //圈子
    if (self.news.circle_arr.count > 0) {
        
        //字符串拼接
        NSString * circleTitle = [NSString stringWithFormat:@"%@：%@", KHClubString(@"News_NewsList_CircleFrom"), [self.news.circle_arr componentsJoinedByString:@","]];
        //大小计算
        CGSize circleSize      = [ToolsManager getSizeWithContent:circleTitle andFontSize:12 andFrame:CGRectMake(0, 0, self.circleBtn.width, MAXFLOAT)];
        if (circleSize.height <= 20) {
            circleSize.height = 20;
        }
        height += circleSize.height+5;
    }
    
    //地址
    if (self.news.location.length > 0) {
        height += 25;
    }
    
//    //圈子
//    if (self.news.circle_arr.count > 0) {
//        height += 25;
//    }
    return height;
}

- (void)registerNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

#pragma mark- override
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.commentTextView resignFirstResponder];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
