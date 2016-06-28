//
//  UIView+JHFollowKeyboard.h
//  JHFollowKeyboardExample
//
//  Created by Jiahai on 14-10-9.
//  Copyright (c) 2014年 Jiahai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,JHFollowKeyboardType) {
    JHFollowKeyboardType_Auto,              //自动计算，是否被遮挡
    JHFollowKeyboardType_Moving             //跟随键盘移动
};

@interface UIView (JHFollowKeyboard)

@property (nonatomic, assign)       CGRect  endKeyboardRect;
@property (nonatomic, assign)       CGFloat deltaY;                 //View移动的距离
@property (nonatomic, assign)       JHFollowKeyboardType jhFollowKeyboardType;

/**
 *  开启视图跟随键盘移动效果
 */
- (void)openFollowKeyboard:(JHFollowKeyboardType)type;
/**
 *  关闭视图跟随键盘移动效果
 */
- (void)closeFollowKeyboard;

@end
