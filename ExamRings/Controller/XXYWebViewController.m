#import "XXYWebViewController.h"
#import "XXYBackButton.h"
@interface XXYWebViewController ()

@end

@implementation XXYWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=XXYBgColor;
    self.navigationItem.title=@"官方网站";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIWebView *webView= [[UIWebView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:webView];
    NSString*urlString=@"http://www.comoclass.com";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 2.设置缓存策略(有缓存就用缓存，没有缓存就重新请求)
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;

//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    webView.userInteractionEnabled=YES;
    webView.scrollView.scrollEnabled = YES;
    webView.scrollView.bounces=NO;
    [webView loadRequest:request];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
