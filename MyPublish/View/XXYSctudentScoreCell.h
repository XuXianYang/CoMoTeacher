#import <UIKit/UIKit.h>
@class XXYStudentInfoListModel;
@interface XXYSctudentScoreCell : UITableViewCell
@property(nonatomic,strong)XXYStudentInfoListModel*dataModel;
@property (weak, nonatomic) IBOutlet UITextField *studentScore;

@end
