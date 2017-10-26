#import <UIKit/UIKit.h>

@protocol XXYReloadTableViewDelegate <NSObject>

-(void)reloadTableView;

@end

@interface XXYCourseListController : UIViewController

@property(nonatomic,weak)id<XXYReloadTableViewDelegate>reloadDelegate;

@property(nonatomic,strong)NSNumber* classId;

@property(nonatomic,strong)NSNumber* dayOfWeek;

@property(nonatomic,strong)NSNumber* lessonOfDay;

@end
