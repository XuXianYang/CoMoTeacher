//
//  XXYHomeworkListModel.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/19.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "JSONModel.h"

@interface XXYHomeworkListModel : JSONModel

@property(nonatomic,assign)NSInteger uid;

@property(nonatomic,assign)NSInteger classId;

@property(nonatomic,assign)NSInteger courseId;

@property(nonatomic,assign)NSInteger createdBy;

@property(nonatomic,assign)NSInteger teacherId;

@property(nonatomic,assign)NSInteger updatedBy;

@property(nonatomic,copy)NSString*createdAt;

@property(nonatomic,copy)NSString*updatedAt;

@property(nonatomic,copy)NSString*myDescription;

@property(nonatomic,copy)NSString* studyDate;

@property(nonatomic,copy)NSString *name;


@end
