//
//  XXYTimeTableModel.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/11.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXYTimeTableModel : NSObject
@property(nonatomic,copy)NSString*courseNum;

@property(nonatomic,copy)NSString*courseName;
@property(nonatomic,copy)NSString*teacherName;


@property(nonatomic,strong)NSNumber* dayOfWeek;

@property(nonatomic,strong)NSNumber* lessonOfDay;

@end
