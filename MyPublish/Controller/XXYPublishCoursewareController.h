#import <UIKit/UIKit.h>
#import "XXYCourseWareListModel.h"

@protocol XXYReloadTableViewDelegate <NSObject>

-(void)reloadTableView;

@end

@interface XXYPublishCoursewareController : UIViewController

@property(nonatomic,weak)id<XXYReloadTableViewDelegate>reloadDelegate;

@property(nonatomic,strong)XXYCourseWareListModel*courseListModel;

@property(nonatomic,assign)NSInteger courseListModelIndex;

@property(nonatomic,copy)NSString*titleName;

@end
