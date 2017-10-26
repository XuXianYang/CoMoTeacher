#import "XXYExamRingsCell.h"
#import "XXYExamContentModel.h"
@interface XXYExamRingsCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation XXYExamRingsCell
-(void)setDataModel:(XXYExamContentModel *)dataModel
{
    _dataModel=dataModel;
    
    _nameLabel.text=dataModel.name;
    _timeLabel.text=[NSString stringWithFormat:@"%@~%@",[self turnDateStringToMyString:dataModel.startTime],[self turnDateStringToMyString:dataModel.endTime]];
    _styleLabel.text=dataModel.courseName;
    _contentLabel.text=dataModel.myDescription;
    
}

-(void)layoutSubviews
{
    _nameLabel.font=[UIFont systemFontOfSize:17];
    
    _timeLabel.font=[UIFont systemFontOfSize:17];
    _timeLabel.textColor=[UIColor lightGrayColor];
    _contentLabel.numberOfLines=0;
    _contentLabel.font=[UIFont systemFontOfSize:17];

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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
