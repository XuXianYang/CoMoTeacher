//
//  AppDelegate.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/9/27.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//d2097a3ffecb0ab55b73eb75
static NSString *appKey = @"d2097a3ffecb0ab55b73eb75";
static NSString *channel = @"App Store";
static BOOL isProduction = true;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


-(void)showWindowHome:(NSString *)windowType;

-(void)setUpLogOutAppAlert;


@end

