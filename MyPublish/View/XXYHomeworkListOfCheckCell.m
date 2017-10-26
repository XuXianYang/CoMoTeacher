#import "XXYHomeworkListOfCheckCell.h"
#import "XXYHomeworkListOfCheckModel.h"
@interface XXYHomeworkListOfCheckCell()

@property (weak, nonatomic) IBOutlet UILabel *studentName;
@property (weak, nonatomic) IBOutlet UILabel *parentName;

@property (weak, nonatomic) IBOutlet UILabel *homeworkState;

@end

@implementation XXYHomeworkListOfCheckCell
-(void)setDataModel:(XXYHomeworkListOfCheckModel *)dataModel
{
    _dataModel=dataModel;
    
    if(dataModel.studentName)
        _studentName.text=dataModel.studentName;
    else
        _studentName.text=@"-";
    
    if(dataModel.parentName&&dataModel.strReviewTime)
        _parentName.text=[NSString stringWithFormat:@"%@   %@",dataModel.parentName,dataModel.strReviewTime];
    else _parentName.text=@"暂无家长检查作业";
    
    if(dataModel.isSign==true)
    {
        _homeworkState.text=@"已审阅";
        _homeworkState.textColor=[UIColor whiteColor];
        //[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]//青
        _homeworkState.backgroundColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
    }
    else
    {
        _homeworkState.text=@"未审阅";
        //[UIColor colorWithRed:252.0/255 green:100.0/255 blue:100.0/255 alpha:1.0]红
        _homeworkState.textColor=[UIColor whiteColor];
        _homeworkState.backgroundColor=[UIColor colorWithRed:252.0/255 green:100.0/255 blue:100.0/255 alpha:1.0];
    }
    
    
}
-(void)layoutSubviews
{
    _studentName.font=[UIFont systemFontOfSize:17];
     _homeworkState.layer.masksToBounds = YES;
    _homeworkState.layer.cornerRadius=5;
    _homeworkState.textAlignment=NSTextAlignmentCenter;
    _homeworkState.font=[UIFont systemFontOfSize:14];
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
