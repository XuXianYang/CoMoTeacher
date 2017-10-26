#import "XXYScoreCell.h"
#import "XXYExamContentModel.h"
@interface XXYScoreCell()
@property (weak, nonatomic) IBOutlet UILabel *quizContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *quizSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *quizStyleLabel;

@end


@implementation XXYScoreCell
-(void)setDatamodel:(XXYExamContentModel *)datamodel
{
    _datamodel=datamodel;
    
    _quizContentLabel.text=datamodel.name;
    _quizSubjectLabel.text=datamodel.courseName;
    _quizStyleLabel.text=[self turnQuizCategoryNumToQuizCategoryName:datamodel.category];
}
-(void)layoutSubviews
{
    _quizContentLabel.font=[UIFont systemFontOfSize:15];
}
-(NSString*)turnQuizCategoryNumToQuizCategoryName:(NSInteger)categoryNum;
{
    NSArray*array=@[@"期中考试",@"期末考试",@"月考"];
    NSString*categoryName;
    
    for(NSInteger i=1;i<4;i++)
    {
        if(categoryNum==i)
        {
            categoryName=array[i-1];
        }
    }
    return categoryName;
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
