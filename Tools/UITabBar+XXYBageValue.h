//
//  UITabBar+XXYBageValue.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/11/17.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (XXYBageValue)
- (void)showBadgeOnItemIndex:(int)index;   //显示小红点
- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
