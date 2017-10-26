#import <UIKit/UIKit.h>
@protocol XXYReloadNewDataDelegate <NSObject>

-(void)reloadNewClassData;

@end

@interface XXYAddClassController : UIViewController

@property(nonatomic,weak)id<XXYReloadNewDataDelegate>reloadDelegate;

@end
