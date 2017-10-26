#import <UIKit/UIKit.h>

#import "XXYAnnouncemmentLIstModel.h"

@protocol XXYReloadTableViewDelegate <NSObject>

-(void)reloadTableView;

@end


@interface XXYPublishAnnouncementController : UIViewController


@property(nonatomic,strong)XXYAnnouncemmentLIstModel*announcemmentModel;

@property(nonatomic,assign)NSInteger announcemmentIndex;

@property(nonatomic,copy)NSString*publishAnnouncemmentTitle;

@property(nonatomic,copy)NSString*classBtnName;

@property(nonatomic,weak)id<XXYReloadTableViewDelegate>reloadDelegate;


@end






