#import "XXYTabBarController.h"
#import "XXYClassController.h"
#import "XXYPublishController.h"
#import "XXYMyInfoController.h"
#import "XXYNavigationController.h"
#import "UIImage+XXYImage.h"

@interface XXYTabBarController ()

@end

@implementation XXYTabBarController

#pragma mark 本类或子类初始化时调用且只调用一次
+ (void)initialize {
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]}
                                             forState:UIControlStateSelected];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加子控制器
    [self setupChildController];
    // 设置tabbarItem
    [self setupTabbarItem];
}
- (void)setupChildController {
    NSArray *classNameArr = @[@"XXYPublishController", @"XXYClassController",@"XXYMyInfoController"];
    for (int i = 0; i < 3; i ++)
    {
        UIViewController *vc= [[NSClassFromString(classNameArr[i]) alloc] init];
        XXYNavigationController *nav = [[XXYNavigationController alloc] initWithRootViewController:vc];
        [self addChildViewController:nav];
    }
}
- (void)setupTabbarItem {
    NSArray *titleArr = @[@"首页", @"班级",@"我"];
    NSArray *imageArr = @[[UIImage imageWithOriginalNamed:@"tabbar_home"], [UIImage imageWithOriginalNamed:@"tabbar_class"],[UIImage imageWithOriginalNamed:@"tabbar_profile"]];
    NSArray *selImageArr = @[[UIImage imageWithOriginalNamed:@"tabbar_home_selected"], [UIImage imageWithOriginalNamed:@"tabbar_class_selected"],[UIImage imageWithOriginalNamed:@"tabbar_profile_selected"]];
    
   
    
    for (int i = 0; i < 3; i ++) {

        UIViewController *vc = self.viewControllers[i];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:titleArr[i] image:imageArr[i] selectedImage:selImageArr[i]];

    }
}
@end
