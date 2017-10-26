#import "XXYClassroomTeachersCell.h"
#import "XXYClassroomTeachersModel.h"

@interface XXYClassroomTeachersCell()

@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UIButton *teacherMobileNo;

@end
@implementation XXYClassroomTeachersCell

-(void)setDataModel:(XXYClassroomTeachersModel *)dataModel
{
    _dataModel=dataModel;
    if(dataModel.teacherName)
    _courseName.text=[NSString stringWithFormat:@"%@:%@",dataModel.courseName,dataModel.teacherName];
    else
        _courseName.text=dataModel.courseName;
    if(dataModel.teacherMobile)
        [_teacherMobileNo setTitle:[NSString stringWithFormat:@"tel:%@",dataModel.teacherMobile] forState:UIControlStateNormal];
    
    else
        [_teacherMobileNo setTitle:[NSString stringWithFormat:@"tel:暂无"] forState:UIControlStateNormal];
}
-(void)layoutSubviews
{
    _courseName.font=[UIFont systemFontOfSize:12];
    _courseName.numberOfLines=2;
       _teacherMobileNo.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _teacherMobileNo.titleLabel.numberOfLines=2;
    _teacherMobileNo.titleLabel.font=[UIFont systemFontOfSize:12];
    [_teacherMobileNo addTarget:self action:@selector(teaNoCliked:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)teaNoCliked:(UIButton*)btn
{
    if(self.dataModel.teacherMobile)
    {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.dataModel.teacherMobile];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self addSubview:callWebview];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
