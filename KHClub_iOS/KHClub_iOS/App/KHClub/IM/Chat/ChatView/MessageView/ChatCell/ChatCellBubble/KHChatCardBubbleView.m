//
//  KHChatCardBubbleView.m
//  KHClub_iOS
//
//  Created by 李晓航 on 15/12/1.
//  Copyright © 2015年 JLXC. All rights reserved.
//

#import "KHChatCardBubbleView.h"
#import "IMUtils.h"

NSString *const kRouterEventCardBubbleTapEventName = @"kRouterEventCardBubbleTapEventName";

@interface KHChatCardBubbleView ()

//@property (nonatomic, strong) UIImageView *locationImageView;
//@property (nonatomic, strong) UILabel *addressLabel;

//头像
@property (nonatomic, strong) CustomImageView * avatarImageView;
//名字
@property (nonatomic, strong) CustomLabel     * nameLabel;
//标题
@property (nonatomic, strong) CustomLabel     * titleLabel;
//线
@property (nonatomic, strong) UIView * lineView;

@end

@implementation KHChatCardBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        //头像
        self.avatarImageView          = [[CustomImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        //姓名
        self.nameLabel                = [[CustomLabel alloc] initWithFontSize:14];
        self.nameLabel.textColor      = [UIColor colorWithHexString:ColorDeepBlack];
        //标题
        self.titleLabel               = [[CustomLabel alloc] initWithFontSize:14];
        self.titleLabel.textColor     = [UIColor colorWithHexString:ColorDeepGary];
        //线
        self.lineView                 = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithHexString:ColorGary];
        
        [self addSubview:self.lineView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.nameLabel];
        [self addSubview:self.avatarImageView];
        
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    
    return CGSizeMake(CARD_WIDTH + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, 2 * BUBBLE_VIEW_PADDING + CARD_HEIGHT);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.model.isSender) {
        frame.origin.x = BUBBLE_VIEW_PADDING;
    }else{
        frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = BUBBLE_VIEW_PADDING;
    
    self.titleLabel.frame      = CGRectMake(frame.origin.x+3, 5, 100, 25);
    self.lineView.frame        = CGRectMake(frame.origin.x+3, 32, frame.size.width-6, 1);
    self.avatarImageView.frame = CGRectMake(frame.origin.x+3, 40, 45, 45);
    self.nameLabel.frame       = CGRectMake(self.avatarImageView.right+5, 38, frame.size.width-self.avatarImageView.right-15, 30);
    
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    
    [super setModel:model];
    
    NSDictionary * cardDic = [[IMUtils shareInstance] cardMessageDecode:model.content];
    if (cardDic.count > 0) {
        if ([cardDic[@"type"] integerValue] == eConversationTypeChat) {
            self.titleLabel.text = KHClubString(@"IM_Card_Card");
            //设置内容
            [[IMUtils shareInstance] setUserNickWith:cardDic[@"id"] and:self.nameLabel andPlaceHolder:cardDic[@"title"]];
            [[IMUtils shareInstance] setUserAvatarWith:cardDic[@"id"] and:self.avatarImageView andPlaceHolder:cardDic[@"avatar"]];
        }else{
            self.titleLabel.text = KHClubString(@"IM_Card_GroupCard");
            //设置内容
            [[IMUtils shareInstance] setGroupNameWith:cardDic[@"id"] and:self.nameLabel andGroupTitle:cardDic[@"title"]];
            [[IMUtils shareInstance] setGroupImageWith:cardDic[@"id"] and:self.avatarImageView];
        }
    }
    
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventCardBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 2 * BUBBLE_VIEW_PADDING + CARD_HEIGHT;
}

@end
