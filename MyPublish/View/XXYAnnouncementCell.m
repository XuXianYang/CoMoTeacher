#import "XXYAnnouncementCell.h"
#import "XXYAnnouncemmentLIstModel.h"
@interface XXYAnnouncementCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *publishTimeLabel;


@property (weak, nonatomic) IBOutlet UILabel *annourcementTitleLabel;


@end


@implementation XXYAnnouncementCell
-(void)setDatamodel:(XXYAnnouncemmentLIstModel *)datamodel
{
    _datamodel=datamodel;
    
    _titleLable.text=datamodel.title;
    _publishTimeLabel.text=datamodel.content;
    if(datamodel.createdAt)
        _contentLabel.text=[self turnDateStringToMyString:datamodel.createdAt];
    else
        _contentLabel.text=@"-";
    
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
    _titleLable.font=[UIFont systemFontOfSize:17];
    
    _publishTimeLabel.font=[UIFont systemFontOfSize:17];
    _contentLabel.textColor=[UIColor lightGrayColor];
    _contentLabel.font=[UIFont systemFontOfSize:17];
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
