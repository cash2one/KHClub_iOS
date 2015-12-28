//
//  CircleNoticeDetailViewController.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/24.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "CircleNoticeDetailViewController.h"
#import "LikeModel.h"
#import "UIButton+WebCache.h"
#import "LikeListCell.h"
#import "CommentModel.h"
#import "NewsCommentCell.h"
#import "HPGrowingTextView.h"
#import "OtherPersonalViewController.h"
#import "CircleNoticeModel.h"

@interface CircleNoticeDetailViewController ()<NewsCommentDelegate,HPGrowingTextViewDelegate>

//时间
@property (nonatomic, strong) CustomLabel       * timeLabel;
//内容
@property (nonatomic, strong) CustomLabel       * contentLabel;
//点赞按钮
@property (nonatomic, strong) CustomButton      * likeBtn;
//点赞数量按钮
@property (nonatomic, strong) CustomButton      * likeCountBtn;
//评论数量按钮
@property (nonatomic, strong) CustomButton      * commentCountBtn;
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
//公告模型
@property (nonatomic, strong) CircleNoticeModel * notice;

//当前是点赞列表 还是 评论列表
@property (nonatomic, assign) BOOL              isLikeOrComment;

@end

@implementation CircleNoticeDetailViewController

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
    //时间
    self.timeLabel                  = [[CustomLabel alloc] init];
    //内容
    self.contentLabel               = [[CustomLabel alloc] init];
    //点赞
    self.likeBtn                    = [[CustomButton alloc] init];
    //点赞数量
    self.likeCountBtn               = [[CustomButton alloc] init];
    //评论数量
    self.commentCountBtn            = [[CustomButton alloc] init];
    
    [self.likeBtn addTarget:self action:@selector(sendLikeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.commentCountBtn addTarget:self action:@selector(choiceCommentList:) forControlEvents:UIControlEventTouchUpInside];
    [self.likeCountBtn addTarget:self action:@selector(choiceLikeList:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configUI
{
    [self setNavBarTitle:KHClubString(@"News_NewsDetail_Tilte")];
    
    self.contentLabel.frame         = CGRectMake(10, 15, self.viewWidth-20, 0);
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.font          = [UIFont systemFontOfSize:FontListContent];
    self.contentLabel.textColor     = [UIColor colorWithHexString:ColorDeepBlack];
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;

    //时间
    self.timeLabel.frame            = CGRectMake(self.contentLabel.x, 0, 250, 12);
    self.timeLabel.font             = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor        = [UIColor colorWithHexString:ColorLightBlack];

    //点赞
    self.likeBtn.titleLabel.font    = [UIFont systemFontOfSize:12];
    self.likeBtn.titleEdgeInsets    = UIEdgeInsetsMake(0, 15, 0, 0);
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
    self.newsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusHeight, self.viewWidth, self.viewHeight-kNavBarAndStatusHeight-40) style:UITableViewStyleGrouped];

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
        LikeModel * model                  = self.notice.like_arr[indexPath.row];
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
    [backView addSubview:self.timeLabel];
    [backView addSubview:self.contentLabel];
    [backView addSubview:self.likeBtn];
    [backView addSubview:self.commentCountBtn];
    [backView addSubview:self.likeCountBtn];
    
    NSMutableParagraphStyle * para               = [[NSMutableParagraphStyle alloc] init];
    para.lineBreakMode                           = NSLineBreakByCharWrapping;
    para.lineSpacing                             = 10;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:self.notice.content_text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, [self.notice.content_text length])];
    self.contentLabel.attributedText             = attributedString;
    [self.contentLabel sizeToFit];

    //底部位置
    CGFloat bottomPosition = self.contentLabel.bottom;

    //时间
    NSString * timeStr       = [ToolsManager compareCurrentTime:self.notice.publish_date];
    self.timeLabel.y         = bottomPosition+15;
    self.timeLabel.text      = timeStr;
    
    //点赞按钮
    self.likeBtn.frame      = CGRectMake([DeviceManager getDeviceWidth]-65, bottomPosition+11, 60, 20);
    if (self.notice.is_like) {
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
    }
    
    bottomPosition           = self.timeLabel.bottom;
    //线
    UIView * lineView        = [[UIView alloc] initWithFrame:CGRectMake(0, bottomPosition+10, self.viewWidth, 10)];
    lineView.backgroundColor = [UIColor colorWithHexString:ColorLightGary];
    [backView addSubview:lineView];
    bottomPosition = lineView.bottom;
    
    //评论
    self.commentCountBtn.frame = CGRectMake(self.timeLabel.x, bottomPosition, 80, 40);
    [self.commentCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Comment"),self.notice.comment_quantity] forState:UIControlStateNormal];
    
    //点赞
    self.likeCountBtn.frame = CGRectMake(self.viewWidth-60, bottomPosition, 50, 40);
    [self.likeCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Like"), self.notice.like_quantity] forState:UIControlStateNormal];
    
    //点赞头像 最多3个 大小根据分辨率算
    NSInteger likeCout = self.notice.like_arr.count;
    if (likeCout > 3) {
        likeCout = 3;
    }
    for (int i=0; i<likeCout; i++) {
        
        LikeModel * like           = self.notice.like_arr[i];
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
        return self.notice.like_arr.count;
    }
    return self.notice.comment_arr.count;
}

//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果是点赞列表
    if (self.isLikeOrComment) {
        return 60;
    }
    
    CommentModel * comment = self.notice.comment_arr[indexPath.row];
    
    NSString * content = comment.comment_content;
    //回复别人的
    if (comment.target_id > 0) {
        NSString * reply = KHClubString(@"News_NewsDetail_Reply");
        content = [NSString stringWithFormat:@"%@%@：%@", reply, [ToolsManager emptyReturnNone:comment.target_name], comment.comment_content];
    }
    
    CGSize contentSize = [ToolsManager getSizeWithContent:content andFontSize:FontComment andFrame:CGRectMake(0, 0, [DeviceManager getDeviceWidth]-15-55, MAXFLOAT)];

    CGFloat total      = 50+contentSize.height;
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
        [cell setContentWithModel:self.notice.like_arr[indexPath.row]];
        return cell;
    }
    
    NewsCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld", indexPath.row]];
    if (!cell) {
        cell = [[NewsCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"cell%ld", indexPath.row]];
        cell.delegate = self;
    }
    [cell setContentWithModel:self.notice.comment_arr[indexPath.row]];
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
                              @"news_id":[NSString stringWithFormat:@"%ld", self.notice.nid]};
    debugLog(@"%@ %@", @"", params);
    [self showLoading:StringCommonUploadData];
    [HttpService postWithUrlString:@"" params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self showComplete:KHClubString(@"News_NewsDetail_DeleteSuccess")];
            //成功之后更新
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.notice.comment_arr indexOfObject:comment]inSection:0];
            [self.notice.comment_arr removeObject:comment];
            [self.newsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //评论减少
            self.notice.comment_quantity --;
            //UI更新
            [self.commentCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Comment"), self.notice.comment_quantity] forState:UIControlStateNormal];
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

//点赞或者取消赞点击
- (void)sendLikeClick {

    UserModel * user  = [UserService sharedService].user;

    BOOL likeOrCancel = YES;
    //先修改在进行网络请求
    if (self.notice.is_like) {
        self.notice.is_like = NO;
        likeOrCancel        = NO;
        self.notice.like_quantity --;
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_normal"] forState:UIControlStateNormal];
        //页面刷新
        for (LikeModel * likeModel in self.notice.like_arr) {
            if (likeModel.user_id == user.uid) {
                [self.notice.like_arr removeObject:likeModel];
                [self.newsTable reloadData];
                break;
            }
        }
        
    }else{
        self.notice.is_like = YES;
        self.notice.like_quantity ++;
        [self.likeBtn setImage:[UIImage imageNamed:@"like_btn_press"] forState:UIControlStateNormal];
        //界面刷新
        LikeModel * like    = [[LikeModel alloc] init];
        like.user_id        = user.uid;
        like.name           = user.name;
        like.head_image     = user.head_image;
        like.head_sub_image = user.head_sub_image;
        [self.notice.like_arr insertObject:like atIndex:0];
        [self.newsTable reloadData];
        
    }
    [self.likeCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Like"), self.notice.like_quantity] forState:UIControlStateNormal];
    
    NSDictionary * params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                              @"notice_id":[NSString stringWithFormat:@"%ld", self.notice.nid],
                              @"isLike":[NSString stringWithFormat:@"%d", likeOrCancel]};
    debugLog(@"%@ %@", kNoticeLikeOrCancelPath, params);
    //成功失败都没反应
    [HttpService postWithUrlString:kNoticeLikeOrCancelPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
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
    LikeModel * like           = self.notice.like_arr[sender.tag];
    [self browsePersonalHome:like.user_id];
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
    opvc.uid                           = userId;
    [self pushVC:opvc];
}

- (void)getData
{
    NSString * url = [NSString stringWithFormat:@"%@?id=%ld&user_id=%ld", kGetNoticeDetailsPath, self.noticeID, [UserService sharedService].user.uid];
    debugLog(@"%@", url);
    [HttpService getWithUrlString:url andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            
            NSDictionary * noticeDic        = responseData[HttpResult];
            NSDictionary * noticeContentDic = noticeDic[@"notice"];
            //数据处理
            CircleNoticeModel * notice      = [[CircleNoticeModel alloc] init];
            notice.content_text             = noticeContentDic[@"content_text"];
            notice.nid                      = [noticeContentDic[@"id"] integerValue];
            notice.publish_date             = noticeContentDic[@"add_date"];
            notice.comment_quantity         = [noticeContentDic[@"comment_quantity"] integerValue];
            notice.like_quantity            = [noticeContentDic[@"like_quantity"] integerValue];
            notice.is_like                  = [noticeContentDic[@"is_like"] boolValue];

            NSArray * comments              = noticeDic[@"commentList"];
            NSArray * likes                 = noticeDic[@"likes"];
            //评论数组
            for (NSDictionary * commentDic in comments) {
                CommentModel * comment  = [[CommentModel alloc] init];
                [comment setContentWithDic:commentDic];
                [notice.comment_arr addObject:comment];
            }
            //点赞数组
            for (NSDictionary * likeDic in likes) {
                LikeModel * like    = [[LikeModel alloc] init];
                like.head_image     = likeDic[@"head_image"];
                like.head_sub_image = likeDic[@"head_sub_image"];
                like.user_id        = [likeDic[@"user_id"] integerValue];
                like.name           = likeDic[@"name"];
                like.job            = likeDic[@"job"];
                [notice.like_arr addObject:like];
            }
            NSInteger userID = [noticeContentDic[@"user_id"] integerValue];
            //如果是自己柯以删除
            if (userID == [UserService sharedService].user.uid) {
                self.navBar.rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
                //右上角设置
                __weak typeof(self) weakSelf = self;
                [self.navBar setRightBtnWithContent:@"" andBlock:^{
                    [weakSelf deleteNewsClick];
                }];
                [self.navBar.rightBtn setImage:[UIImage imageNamed:@"delete_btn_normal"] forState:UIControlStateNormal];
                self.navBar.rightBtn.hidden = NO;
            }else{
                self.navBar.rightBtn.hidden = YES;
            }
            
            self.notice = notice;
            [self initTable];
        }else{
            [self showWarn:StringCommonNetException];
            
        }
        
    } andFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self showWarn:StringCommonNetException];
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
                              @"notice_id"  :[NSString stringWithFormat:@"%ld", self.noticeID]};
    if (self.currentTopComment != nil) {
        params = @{@"user_id":[NSString stringWithFormat:@"%ld", [UserService sharedService].user.uid],
                   @"comment_content":self.commentTextView.text,
                   @"notice_id":[NSString stringWithFormat:@"%ld", self.noticeID],
                   @"target_id":[NSString stringWithFormat:@"%ld", self.currentTopComment.user_id],
                   @"target_name":self.currentTopComment.name};
    }
    
    [self showLoading:nil];
    debugLog(@"%@ %@", kSendNoticeCommentPath, params);
    [HttpService postWithUrlString:kSendNoticeCommentPath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        debugLog(@"%@", responseData);
        int status = [responseData[HttpStatus] intValue];
        if (status == HttpStatusCodeSuccess) {
            [self showComplete:KHClubString(@"News_Publish_Success")];
            //生成评论模型
            CommentModel * comment = [[CommentModel alloc] init];
            [comment setContentWithDic:responseData[HttpResult]];
            [self.notice.comment_arr addObject:comment];
            comment.name           = [UserService sharedService].user.name;
            comment.head_image     = [UserService sharedService].user.head_image;
            comment.head_sub_image = [UserService sharedService].user.head_sub_image;
            comment.job            = [UserService sharedService].user.job;
            comment.target_id      = [params[@"target_id"] integerValue];
            comment.target_name    = params[@"target_name"];
            
            //评论增加
            self.notice.comment_quantity++;
            [self.commentCountBtn setTitle:[NSString stringWithFormat:@"%@ %ld", KHClubString(@"News_NewsDetail_Comment"), self.notice.comment_quantity] forState:UIControlStateNormal];
            
            //更新table
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.notice.comment_arr.count-1 inSection:0];
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
- (void)deleteNewsClick
{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:KHClubString(@"News_Publish_DeleteConfirm") message:nil delegate:self cancelButtonTitle:StringCommonCancel otherButtonTitles:StringCommonConfirm, nil];
    [alert show];
    
}

//删除动态
- (void)confirmDelete
{
    NSDictionary * params = @{@"notice_id":[NSString stringWithFormat:@"%ld", self.noticeID]};
    debugLog(@"%@ %@", kDeleteNoticePath, params);
    
    [self showLoading:StringCommonUploadData];
    [HttpService postWithUrlString:kDeleteNoticePath params:params andCompletion:^(AFHTTPRequestOperation *operation, id responseData) {
        
        int status = [responseData[HttpStatus] intValue];
        
        if (status == HttpStatusCodeSuccess) {
            [self showComplete:KHClubString(@"News_NewsDetail_DeleteSuccess")];
            //发送发送成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_PUBLISH_NOTICE object:nil];
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
    
    NSMutableParagraphStyle * para = [[NSMutableParagraphStyle alloc] init];
    para.lineBreakMode             = NSLineBreakByCharWrapping;
    para.lineSpacing               = 10;
    NSDictionary * dic             = @{NSFontAttributeName : [UIFont systemFontOfSize:FontListContent],
                                       NSParagraphStyleAttributeName : para};
    CGRect rect = [self.notice.content_text boundingRectWithSize:CGSizeMake(self.viewWidth-20, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    
    //总长
    return rect.size.height+102;
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
