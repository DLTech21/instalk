//
//  DDChatVideoCell.m
//  TeamTalk
//
//  Created by Donal Tong on 16/6/21.
//  Copyright © 2016年 DL. All rights reserved.
//

#import "DDChatVideoCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+Addition.h"
#import "NSDictionary+JSON.h"
#import "MTTPhotosCache.h"
#import "MTTDatabaseUtil.h"
#import "DDMessageSendManager.h"
#import "ChattingMainViewController.h"
#import "DDSendPhotoMessageAPI.h"
#import "SessionModule.h"
#import "UIImage+UIImageAddition.h"
#import <Masonry/Masonry.h>
#import <SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <XHImageViewer.h>
#import "NSString+GTMNSString_HTML.h"
@implementation DDChatVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.msgImgView =[[UIImageView alloc] init];
        self.msgImgView.userInteractionEnabled=NO;
        [self.msgImgView setClipsToBounds:YES];
        [self.msgImgView.layer setCornerRadius:5];
        [self.msgImgView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.msgImgView];
        [self.bubbleImageView setClipsToBounds:YES];
    }
    return self;
}

- (void)setContent:(MTTMessageEntity*)content
{
    // 获取气泡设置
    [super setContent:content];
    //设置气泡位置
    UIImage* bubbleImage = nil;
    switch (self.location)
    {
        case DDBubbleLeft:
        {
            bubbleImage = [UIImage imageNamed:self.leftConfig.picBgImage];
            bubbleImage = [bubbleImage stretchableImageWithLeftCapWidth:self.leftConfig.imgStretchy.left topCapHeight:self.leftConfig.imgStretchy.top];
        }
            break;
        case DDBubbleRight:
        {
            bubbleImage = [UIImage imageNamed:self.rightConfig.picBgImage];
            bubbleImage = [bubbleImage stretchableImageWithLeftCapWidth:self.rightConfig.imgStretchy.left topCapHeight:self.rightConfig.imgStretchy.top];
        }
        default:
            break;
    }
    [self.bubbleImageView setImage:bubbleImage];
    if(content.msgContentType == DDMEssageTypeVideo)
    {
        NSDictionary* messageContent = [NSDictionary initWithJsonString:content.msgContent];
        if (content.state == DDmessageSendSuccess) {
            if (messageContent)
            {
                NSString* urlString = [messageContent valueForKey:@"video_cover_url"];
                NSURL* url = [NSURL URLWithString:urlString];
                [self.msgImgView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                }];
            }
        }
        else {
            
        }
    }
    
    
}

#pragma mark DDChatCellProtocol Protocol
- (CGSize)sizeForContent:(MTTMessageEntity*)content
{
    float height = 150;
    float width = 150;
    NSDictionary* messageContent = [NSDictionary initWithJsonString:content.msgContent];
    NSString* urlString = [messageContent valueForKey:@"video_cover_url"];
    NSURL* url = [NSURL URLWithString:urlString];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    if( [manager cachedImageExistsForURL:url]){
        NSString *key = [manager cacheKeyForURL:url];
        UIImage *curImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        height = curImg.size.height>40?150:40;
        width = curImg.size.width>40?150:40;
        return [MTTUtil sizeTrans:CGSizeMake(width, height)];
    }
    return CGSizeMake(width, height);
}

- (float)contentUpGapWithBubble
{
    return 1;
}

- (float)contentDownGapWithBubble
{
    return 1;
}

- (float)contentLeftGapWithBubble
{
    switch (self.location)
    {
        case DDBubbleRight:
            return 1;
        case DDBubbleLeft:
            return 6.5;
    }
    return 0;
}

- (float)contentRightGapWithBubble
{
    switch (self.location)
    {
        case DDBubbleRight:
            return 6.5;
            break;
        case DDBubbleLeft:
            return 1;
            break;
    }
    return 0;
}

- (void)layoutContentView:(MTTMessageEntity*)content
{
    CGSize size = [self sizeForContent:content];
    [self.msgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bubbleImageView.mas_left).offset([self contentLeftGapWithBubble]+1);
        make.top.equalTo(self.bubbleImageView.mas_top).offset([self contentUpGapWithBubble]+1);
        make.size.mas_equalTo(CGSizeMake(size.width-2, size.height-2));
    }];
}

- (float)cellHeightForMessage:(MTTMessageEntity*)message
{
    return 27 + dd_bubbleUpDown;
}

#pragma mark -
#pragma mark DDMenuImageView Delegate
- (void)clickTheSendAgain:(MenuImageView*)imageView
{
    //子类去继承
    if (self.sendAgain)
    {
        self.sendAgain();
    }
}
- (void)sendVideoAgain:(MTTMessageEntity*)message
{
    //子类去继承
    message.state = DDMessageSending;
    [self showSending];
    [[DDMessageSendManager instance] sendMessage:message isGroup:[message isGroupMessage]  Session:[[SessionModule instance] getSessionById:message.sessionId] completion:^(MTTMessageEntity* theMessage,NSError *error) {
        [self showSendSuccess];
    } Error:^(NSError *error) {
        [self showSendFailure];
    }];
    
}

-(void)clickTheDelete:(MenuImageView *)imageView
{
    debugLog(@"ddd");
    if (self.deleteIt)
    {
        self.deleteIt();
    }
}
@end
