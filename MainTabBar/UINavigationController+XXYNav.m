//
//  UINavigationController+XXYNav.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 17/3/21.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import "UINavigationController+XXYNav.h"

@implementation UINavigationController (XXYNav)
- (void)pushViewControllerWithAnimation:(UIViewController*)controller
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.4];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self pushViewController:controller animated:NO];
    [self.view.layer addAnimation:animation forKey:nil];
    
}
- (void)popViewControllerWithAnimation
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.4];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self popViewControllerAnimated:NO];
    [self.view.layer addAnimation:animation forKey:nil];
}

@end
