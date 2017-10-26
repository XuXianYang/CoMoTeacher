//
//  UIScrollView+XXYScrollview.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 2017/4/14.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import "UIScrollView+XXYScrollview.h"

@implementation UIScrollView (XXYScrollview)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [otherGestureRecognizer.view.superview isKindOfClass:[UITableView class]];
}

@end
