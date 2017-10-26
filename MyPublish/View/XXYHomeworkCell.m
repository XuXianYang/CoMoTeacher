//
//  XXYHomeworkCell.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/19.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYHomeworkCell.h"
#import "XXYHomeworkListModel.h"
@interface XXYHomeworkCell()
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UILabel *sendL;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeworkTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *publishTimeLabel;
@end

@implementation XXYHomeworkCell
-(void)setDatamodel:(XXYHomeworkListModel *)datamodel
{
    _datamodel=datamodel;
    _titleLabel.text=datamodel.name;
    _contentLabel.text=datamodel.myDescription;
    
       if(datamodel.studyDate)
        _homeworkTimeLabel.text=[self turnDateStringToMyString:datamodel.studyDate];
    
    else
        _homeworkTimeLabel.text=@"-";
    if(datamodel.updatedAt)
        _publishTimeLabel.text=[self turnDateStringToMyString:datamodel.updatedAt];
    else
        _publishTimeLabel.text=@"-";
    
}
-(NSString*)turnDateStringToMyString:(NSString*)dateString
{
    
    NSArray*array=[dateString componentsSeparatedByString:@" "];
    
    NSString*dayString=[array[1] substringWithRange:NSMakeRange(0,((NSString*)array[1]).length-1)];
    
    NSString*monthString;
    
    NSArray*monArray=@[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
    NSArray*monNumArray=@[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    
    for (int i=0;i<monArray.count;i++) {
        if([array[0] isEqualToString:monArray[i]])
        {
            monthString=monNumArray[i];
        }
    }
    return [NSString stringWithFormat:@"%@-%@-%@",array[2],monthString,dayString];
}

-(void)layoutSubviews
{
    
    _titleL.textColor=XXYCharactersColor;
    _contentL.textColor=XXYCharactersColor;
    _timeL.textColor=XXYCharactersColor;
    _sendL.textColor=XXYCharactersColor;
    
    _titleLabel.textColor=XXYCharactersColor;
    _contentLabel.textColor=XXYCharactersColor;
    
    _titleLabel.font=[UIFont systemFontOfSize:17];
    _titleLabel.numberOfLines=1;
    
    _homeworkTimeLabel.font=[UIFont systemFontOfSize:15];
    _homeworkTimeLabel.textColor=[UIColor lightGrayColor];
    
    _publishTimeLabel.font=[UIFont systemFontOfSize:15];
    _publishTimeLabel.textColor=[UIColor lightGrayColor];
    
    _contentLabel.numberOfLines=0;
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
