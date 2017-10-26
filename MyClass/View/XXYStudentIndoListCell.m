#import "XXYStudentIndoListCell.h"
#import "XXYStudentInfoListModel.h"
@interface XXYStudentIndoListCell()

@property (weak, nonatomic) IBOutlet UILabel *studentName;
@property (weak, nonatomic) IBOutlet UIButton *studentMobileNo;

@property (weak, nonatomic) IBOutlet UILabel *enroClassTime;
@property (weak, nonatomic) IBOutlet UILabel *parentName;
@property (weak, nonatomic) IBOutlet UIButton *parentmobileNo;

@end
@implementation XXYStudentIndoListCell
-(void)setDataModel:(XXYStudentInfoListModel *)dataModel
{
    _dataModel=dataModel;
    if(dataModel.realName)
    _studentName.text=dataModel.realName;
    else
        _studentName.text=@"暂无";
    if(dataModel.mobileNo)
        [_studentMobileNo setTitle:dataModel.mobileNo forState:UIControlStateNormal];
    else
        [_studentMobileNo setTitle:@"暂无" forState:UIControlStateNormal];
    if(dataModel.joinClassAt)
    _enroClassTime.text=[NSString stringWithFormat:@"%@ 入班",[self turnDateStringToMyString:dataModel.joinClassAt]];
    else _enroClassTime.text=@"暂无";
    if(dataModel.parentName)
    _parentName.text=dataModel.parentName;
    else _parentName.text=@" 暂无";
    
    if(dataModel.parentMobileNo.length>0)
        [_parentmobileNo setTitle:dataModel.parentMobileNo forState:UIControlStateNormal];
    else
        [_parentmobileNo setTitle:@"暂无" forState:UIControlStateNormal];
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
    _studentName.font=[UIFont systemFontOfSize:17];
    _studentMobileNo.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _studentMobileNo.titleLabel.textAlignment=NSTextAlignmentLeft;
    _studentMobileNo.titleLabel.font=[UIFont systemFontOfSize:17];
    [_studentMobileNo addTarget:self action:@selector(stuNoClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _enroClassTime.font=[UIFont systemFontOfSize:12];
    _enroClassTime.textColor=[UIColor lightGrayColor];
    _parentmobileNo.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _parentmobileNo.titleLabel.font=[UIFont systemFontOfSize:17];
    [_parentmobileNo addTarget:self action:@selector(parNoClicked:) forControlEvents:UIControlEventTouchUpInside];
    _parentName.font=[UIFont systemFontOfSize:17];
}
-(void)stuNoClicked:(UIButton*)btn
{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",btn.currentTitle];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self addSubview:callWebview];

}
-(void)parNoClicked:(UIButton*)btn
{
    if(btn.currentTitle.length>10)
    {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",[btn.currentTitle substringWithRange:NSMakeRange(0, 11)]];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self addSubview:callWebview];
 
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
