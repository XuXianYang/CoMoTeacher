#import "XXYSctudentScoreCell.h"
#import "XXYStudentInfoListModel.h"

@interface XXYSctudentScoreCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobelLabel;
@property (weak, nonatomic) IBOutlet UILabel *parentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *parentMobelLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *studentIcon;
@property (weak, nonatomic) IBOutlet UIImageView *parentIcon;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
@implementation XXYSctudentScoreCell
-(void)setDataModel:(XXYStudentInfoListModel *)dataModel
{
    _dataModel=dataModel;
    
    if(dataModel.realName)
        _nameLabel.text=dataModel.realName;
    else
        _nameLabel.text=@"-";
    
    if(dataModel.mobileNo)
        _mobelLabel.text=dataModel.mobileNo;
    else _mobelLabel.text=@"暂无";
    
        if(dataModel.parentName)
        _parentNameLabel.text=dataModel.parentName;
    else _parentNameLabel.text=@"暂无";
    
    if(dataModel.parentMobileNo)
        _parentMobelLabel.text=dataModel.parentMobileNo;
    else _parentMobelLabel.text=@"暂无";

    
    _numberLabel.text=[NSString stringWithFormat:@"%i",dataModel.studentId];
    
    _studentScore.text=dataModel.stuScore;
    
}
-(void)layoutSubviews
{
    _nameLabel.font=[UIFont systemFontOfSize:15];
    _mobelLabel.textColor=[UIColor lightGrayColor];
    _parentMobelLabel.textColor=[UIColor lightGrayColor];
    _studentIcon.layer.masksToBounds=YES;
    _studentIcon.layer.cornerRadius=15;
    _parentIcon.layer.cornerRadius=15;
    _parentIcon.layer.masksToBounds=YES;
    _mobelLabel.font=[UIFont systemFontOfSize:12];
    _parentMobelLabel.font=[UIFont systemFontOfSize:12];
    _lineView.backgroundColor=[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0];
    _studentScore.backgroundColor=[UIColor colorWithRed:1.0/255 green:188.0/255 blue:181.0/255 alpha:1.0];
    _studentScore.textColor=[UIColor whiteColor];
    _studentScore.userInteractionEnabled=NO;
   
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
