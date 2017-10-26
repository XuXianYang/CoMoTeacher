#import "XXYNullViewController.h"

@interface XXYNullViewController ()

@end

@implementation XXYNullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.clipsToBounds=YES;
    imageView.contentMode=UIViewContentModeScaleAspectFill;    imageView.image=[UIImage imageNamed:@"guide_home"];
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
