#import <UIKit/UIKit.h>

@protocol XXYReloadTableViewDelegate <NSObject>

-(void)reloadTableView;

@end

@interface XXYScoreSettingController : UIViewController

@property(nonatomic,weak)id<XXYReloadTableViewDelegate>reloadDelegate;
@property(nonatomic,copy)NSString*titleName;
@property(nonatomic,copy)NSString*studentScore;
@property(nonatomic,copy)NSString*studentId;
@property(nonatomic,strong)NSNumber*classId;
@property(nonatomic,strong)NSNumber*quizId;

@end
