//
//  DDChatVideoCell.h
//  TeamTalk
//
//  Created by Donal Tong on 16/6/21.
//  Copyright © 2016年 DL. All rights reserved.
//

#import "DDChatBaseCell.h"

@interface DDChatVideoCell : DDChatBaseCell <DDChatCellProtocol>
@property(nonatomic,strong)UIImageView *msgImgView;
- (void)sendVideoAgain:(MTTMessageEntity*)message;

@end
