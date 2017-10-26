#import "XXYLittleReportCell.h"
#import "XXYLittleReportModel.h"
@interface  XXYLittleReportCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
@implementation XXYLittleReportCell
-(void)setDataModel:(XXYLittleReportModel *)dataModel
{
    _dataModel=dataModel;
    if(dataModel.realName&&dataModel.className)
    _nameLabel.text=[NSString stringWithFormat:@"%@  %@  报告:",dataModel.className,dataModel.realName];
    else
        _nameLabel.text=@"-";

    _timeLabel.text=[self turnDateStringToMyString:dataModel.createdAt];
    
    
    //设置缩进、行距
    NSMutableParagraphStyle *style2 = [[NSMutableParagraphStyle alloc] init];
    style2.headIndent = 10;
    style2.firstLineHeadIndent = 10;
    style2.lineSpacing = 5;
    style2.minimumLineHeight=5;
    style2.maximumLineHeight=25;
    
    NSString*contentString=[NSString stringWithFormat:@"\n%@\n",dataModel.content];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:contentString];
    [text addAttribute:NSParagraphStyleAttributeName value:style2 range:NSMakeRange(0, text.length)];
     _contentLabel.attributedText = text;
    
}
-(void)layoutSubviews
{
    _nameLabel.font=[UIFont systemFontOfSize:12];
    _nameLabel.textColor=[UIColor colorWithRed:171.0/255 green:171.0/255 blue:171.0/255 alpha:1.0];
    
    _timeLabel.layer.masksToBounds=YES;
    _timeLabel.layer.cornerRadius=5;
    _timeLabel.font=[UIFont systemFontOfSize:12];
    _timeLabel.textColor=[UIColor whiteColor];
    _timeLabel.textAlignment=NSTextAlignmentCenter;
    _timeLabel.backgroundColor=[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0];
    
    _contentLabel.font=[UIFont systemFontOfSize:15];
    _contentLabel.textColor=[UIColor colorWithRed:171.0/255 green:171.0/255 blue:171.0/255 alpha:1.0];
    _contentLabel.numberOfLines=0;
    _contentLabel.backgroundColor=[UIColor whiteColor];
    switch (self.index)
    {
        case 0:
        {
            _lineView.backgroundColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
        }
            break;
        case 1:
        {
            _lineView.backgroundColor=[UIColor colorWithRed:253.0/255 green:231.0/255 blue:204.0/255 alpha:1.0];
        }
            break;
        default:
            break;
    }
 
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
    
    if(array.count>=4)
    return [NSString stringWithFormat:@"%@-%@-%@ %@",array[2],monthString,dayString,array[3]];
    else
        return @"";
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
