//
//  XXYTimeTableViewCell.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/11.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYTimeTableViewCell.h"
#import "XXYTimeTableModel.h"
@interface XXYTimeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *courseNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *courseImageView;
@property (weak, nonatomic) IBOutlet UIView *bgView;


@end

@implementation XXYTimeTableViewCell


-(void)setDataModel:(XXYTimeTableModel *)dataModel
{
    _dataModel=dataModel;
    _courseNumLabel.text=dataModel.courseNum;
    _courseNameLabel.text=dataModel.courseName;
}
-(void)layoutSubviews
{
    _courseNameLabel.textColor=XXYCharactersColor;
    _courseNumLabel.font=[UIFont systemFontOfSize:15];
    _courseNumLabel.textAlignment=NSTextAlignmentCenter;
    _courseNumLabel.textColor=[UIColor whiteColor];
    
    _courseNameLabel.backgroundColor=[UIColor clearColor];
    _courseNameLabel.font=[UIFont systemFontOfSize:14];

    if(self.index<4)
    {
        _courseImageView.image=[UIImage imageNamed:@"timeTable_3"];
        
        _courseNumLabel.backgroundColor=[UIColor colorWithRed:76.0/255 green:223.0/255 blue:215.0/255 alpha:1.0];
        
        _bgView.backgroundColor=[UIColor colorWithRed:227.0/255 green:255.0/255 blue:254.0/255 alpha:1.0];
    }
    else
    {
        _courseImageView.image=[UIImage imageNamed:@"timeTable_4"];
        
        _courseNumLabel.backgroundColor=[UIColor colorWithRed:253.0/255 green:194.0/255 blue:102.0/255 alpha:1.0];
        
        _bgView.backgroundColor=[UIColor colorWithRed:253.0/255 green:241.0/255 blue:227.0/255 alpha:1.0];
    }
    
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
