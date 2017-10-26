//
//  XXYPublishHomeworkController.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/8.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

#import"XXYHomeworkListModel.h"

@protocol XXYReloadTableViewDelegate <NSObject>

-(void)reloadTableView;

@end

@interface XXYPublishHomeworkController : UIViewController

@property(nonatomic,strong)XXYHomeworkListModel*homeworkModel;

@property(nonatomic,assign)NSInteger homeworkIndex;

@property(nonatomic,copy)NSString*publishHomeworkTitle;

@property(nonatomic,weak)id<XXYReloadTableViewDelegate>reloadDelegate;


@end
