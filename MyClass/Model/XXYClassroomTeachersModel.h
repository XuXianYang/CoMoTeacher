//
//  XXYClassroomTeachersModel.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/31.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "JSONModel.h"

@interface XXYClassroomTeachersModel : JSONModel

@property(nonatomic,assign)NSInteger courseId;
@property(nonatomic,copy)NSString*courseName;
@property(nonatomic,assign)NSInteger teacherId;
@property(nonatomic,copy)NSString*teacherName;
@property(nonatomic,copy)NSString*teacherMobile;


@end
