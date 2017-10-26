//
//  XXYTimeTableViewCell.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/11.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYHomeTimeTableViewCell.h"
#import "XXYTimeTableModel.h"
@interface XXYHomeTimeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *weekDayName;
@property (weak, nonatomic) IBOutlet UIImageView *courseImage;
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UIImageView *teacherImage;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UIView *courseContent;

@end

@implementation XXYHomeTimeTableViewCell


-(void)setDataModel:(XXYTimeTableModel *)dataModel
{
    _dataModel=dataModel;
    _teacherName.numberOfLines=0;
    _weekDayName.text=dataModel.courseNum;
    _courseName.text=dataModel.courseName;
    _teacherName.text=dataModel.teacherName;
    
    if(self.index<4)
    {
        _courseImage.image=[UIImage imageNamed:@"timeTable_1"];
        _teacherImage.image=[UIImage imageNamed:@"timeTable_3"];
        
        _weekDayName.backgroundColor=[UIColor colorWithRed:60.0/255 green:147.0/255 blue:255.0/255 alpha:1.0];
        
        _courseContent.backgroundColor=[UIColor colorWithRed:231.0/255 green:242.0/255 blue:255.0/255 alpha:1.0];
    }
    else
    {
        _courseImage.image=[UIImage imageNamed:@"timeTable_2"];
        _teacherImage.image=[UIImage imageNamed:@"timeTable_4"];
        
        _weekDayName.backgroundColor=[UIColor colorWithRed:255.0/255 green:166.0/255 blue:72.0/255 alpha:1.0];
        
        _courseContent.backgroundColor=[UIColor colorWithRed:255.0/255 green:242.0/255 blue:231.0/255 alpha:1.0];
        
    }
}

-(void)layoutSubviews
{
    _weekDayName.textColor=[UIColor whiteColor];
    _weekDayName.textAlignment=NSTextAlignmentCenter;
    _courseName.font=[UIFont systemFontOfSize:14];
    _teacherName.font=[UIFont systemFontOfSize:13];
    _teacherName.numberOfLines=0;
    _weekDayName.font=[UIFont systemFontOfSize:15];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
