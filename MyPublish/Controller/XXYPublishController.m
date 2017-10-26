#import "XXYPublishController.h"
#import "XXYHomeworkController.h"
#import "XXYCoursewareController.h"
#import "XXYScoreController.h"
#import "XXYAnnouncementController.h"
#import "XXYTimeTableController.h"
#import "BSHttpRequest.h"
#import "AFNetworking.h"
#import "XXYExamRiingsController.h"
#import "XXYLittleReportController.h"
#import"XXYClassGroupController.h"
#import "XXYTimeTableController.h"
#import "RongIMKit/RongIMKit.h"
#import "UITabBar+XXYBageValue.h"
#import "UIView+XXYBageValue.h"

@interface XXYPublishController ()<UIScrollViewDelegate,XXYSendClearMessageInfoDelegate>

@property(nonatomic,strong)UIScrollView*scrollView;
@property(nonatomic,strong)UIPageControl*pageControl;
@property(nonatomic,strong)UIScrollView*adScrollView;
@property(nonatomic,strong)UIView*bgView;
@property(nonatomic,strong)UILabel*groupChatLabel;
@property(nonatomic,copy)NSString*groupChatId;

@property(nonatomic,assign)CGFloat adHeight;

@end

@implementation XXYPublishController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"])
    {
        _adHeight=300;
    }
    else
    {
        _adHeight=150;
    }
    [self setUpAds];
    [self addButtons];
    [self getFirstClassInfo];
    [self judgeNetworkConnection];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    
    SVProgressHUD.minimumDismissTimeInterval=1.5  ;
    SVProgressHUD.maximumDismissTimeInterval=2.0  ;
}
- (void)didReceiveMessageNotification:(NSNotification *)notification
{
    [_groupChatLabel showBadgeOnItemIndex:1000];
    [self.navigationController.tabBarController.tabBar showBadgeOnItemIndex:0];
    
    RCMessage*message=notification.object;
    _groupChatId=message.targetId;
   // NSLog(@"123:%@",_groupChatId);
}
-(void)clearMessage
{
    [_groupChatLabel hideBadgeOnItemIndex:1000];
    [self.navigationController.tabBarController.tabBar hideBadgeOnItemIndex:0];
    _groupChatId=nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    //状态栏颜色为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationItem.title=@"";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
}
-(void)judgeNetworkConnection
{
    //网络监控句柄
    AFNetworkReachabilityManager *manager1 = [AFNetworkReachabilityManager sharedManager];
    //要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager1 startMonitoring];
    [manager1 setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //status:
        //AFNetworkReachabilityStatusUnknown          = -1,  未知
        //AFNetworkReachabilityStatusNotReachable     = 0,   未连接
        //AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G
        //AFNetworkReachabilityStatusReachableViaWiFi = 2,   无线连接
        if(status==AFNetworkReachabilityStatusNotReachable)
        {
            [self showMessage:@"连接超时,请检查你的网络!" duration:10.0];
        }
    }];
}
-(void)showMessage:(NSString *)message duration:(NSTimeInterval)time
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor grayColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f],
                                 NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [message boundingRectWithSize:CGSizeMake(207, 999)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes context:nil].size;
    label.frame = CGRectMake(10, 5, labelSize.width +20, labelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    
    showview.frame = CGRectMake((screenSize.width - labelSize.width - 20)/2,
                                screenSize.height/2,
                                labelSize.width+40,
                                labelSize.height+10);
    
    [UIView animateWithDuration:time animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}
-(void)getFirstClassInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
//    NSLog(@"sid=%@",userSidString);
    NSArray*classListArray=[defaults objectForKey:@"teacherClassList"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/list"];
    if(classListArray.count<=0)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        if(array.count>0)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:array[0] forKey:@"firstClassInfo"];
            [defaults setObject:array forKey:@"teacherClassList"];
        }
    } failure:^(NSError *error) {
    }];
}
-(void)setUpAds
{
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,-44, MainScreenW, MainScreenH)];
    _scrollView.backgroundColor=XXYBgColor;
    _scrollView.bounces=YES;
    _scrollView.showsVerticalScrollIndicator=NO;
   
    _scrollView.contentSize=CGSizeMake(0, _adHeight+(MainScreenW-130)/4+55+65*4+30);
    [self.view addSubview:_scrollView];

    //广告
    NSArray*imageNameArray=@[@"homeslide2",@"homeslide1"];
    _adScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, _adHeight)];
    _adScrollView.backgroundColor=[UIColor clearColor];
    _adScrollView.pagingEnabled=YES;
    _adScrollView.showsHorizontalScrollIndicator=NO;
    _adScrollView.bounces=NO;
    _adScrollView.scrollEnabled=YES;
    _adScrollView.contentSize=CGSizeMake(MainScreenW*imageNameArray.count, 0);
    _adScrollView.delegate=self;
    _adScrollView.tag=100;
    [_scrollView addSubview:_adScrollView];
    
    for(int i=0;i<imageNameArray.count;i++)
    {
        UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(i*MainScreenW, 0, MainScreenW, MainScreenW*2/5)];
        imageView.image=[UIImage imageNamed:imageNameArray[i]];
        imageView.userInteractionEnabled = YES;
        [_adScrollView addSubview:imageView];
    }
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(100,_adHeight-35, MainScreenW-200, 20)];
    _pageControl.numberOfPages=imageNameArray.count;
    _pageControl.currentPage=0;
    _pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
    _pageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
    [_scrollView addSubview:_pageControl];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag==100)
    {
        NSInteger index=scrollView.contentOffset.x/scrollView.frame.size.width;
        self.pageControl.currentPage=index;
    }
}
-(void)addButtons
{
    CGFloat imageWidth=(MainScreenW-30-20*5)/4;
    CGFloat bgViewH=imageWidth+20+35;
    UIView*btnBgView=[[UIView alloc]initWithFrame:CGRectMake(15, MainScreenW*2/5+35-24, MainScreenW-30, bgViewH)];
    btnBgView.backgroundColor=[UIColor whiteColor];
    [_scrollView addSubview:btnBgView];
    NSArray*imageNameArray=@[@"home_courseware",@"home_homework",@"home_score",@"home_annourcement"];
    
    NSArray*labelName=@[@"发布课件",@"发布作业",@"发布成绩",@"发布公告"];
    for(int i=0;i<4;i++)
    {
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(20+i*(imageWidth+20), 20, imageWidth, imageWidth);
        [btn setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
        btn.tag=200+i;
        [btn addTarget:self action:@selector(publishBtnCilked:) forControlEvents:UIControlEventTouchUpInside];
        [btnBgView addSubview:btn];
        
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(20+i*(imageWidth+20), 20+imageWidth, imageWidth, 30)];
        label.text=labelName[i];
        label.textColor=XXYCharactersColor;
        label.textAlignment=NSTextAlignmentCenter;
        //根据字体宽度让字体自适应大小
        label.adjustsFontSizeToFitWidth = YES;
        [btnBgView addSubview:label];
        
    }
    NSArray*listImageName=@[@"home_report",@"home_rings",@"home_timetable",@"home_clusteredclass"];
    NSArray*listLabelName=@[@"考试铃",@"小报告",@"课程表",@"班群"];
    for(int i=0;i<4;i++)
    {
        UIButton*listBgView=[UIButton buttonWithType:UIButtonTypeSystem];
        listBgView.frame=CGRectMake(15, MainScreenW*2/5+50+bgViewH+65*i-24, MainScreenW-30, 50);
        listBgView.tag=300+i;
        [listBgView addTarget:self action:@selector(listBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        listBgView.backgroundColor=[UIColor whiteColor];
        [_scrollView addSubview:listBgView];
        
        UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 30, 30)];
        imageView.image=[UIImage imageNamed:listImageName[i]];
        [listBgView addSubview:imageView];
        
        UILabel*listLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 10, 100, 30)];
        listLabel.text=listLabelName[i];
        listLabel.textColor=XXYCharactersColor;
        [listBgView addSubview:listLabel];
        
        if(i==3)
        {
            _groupChatLabel=listLabel;
        }

        UIImageView*goImageView=[[UIImageView alloc]initWithFrame:CGRectMake(MainScreenW-75, 15, 20, 20)];
        goImageView.image=[UIImage imageNamed:@"icon_img"];
        [listBgView addSubview:goImageView];
    }
}

-(void)listBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary*firstClassInfo=[defaults objectForKey:@"firstClassInfo"];
    
    if(!firstClassInfo)
    {
        [SVProgressHUD showErrorWithStatus:@"请点击班级,然后点击'+'加入班级"];
    }
    else

    switch (btn.tag) {
        case 300:
        {
            XXYExamRiingsController*publishCon=[[XXYExamRiingsController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
        case 301:
        {
            XXYLittleReportController*publishCon=[[XXYLittleReportController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
        case 302:
        {
            XXYTimeTableController*publishCon=[[XXYTimeTableController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
        case 303:
        {
            [_groupChatLabel hideBadgeOnItemIndex:1000];
            [self.navigationController.tabBarController.tabBar hideBadgeOnItemIndex:0];
            XXYClassGroupController*publishCon=[[XXYClassGroupController alloc]init];
            publishCon.targetId=_groupChatId;
            publishCon.sendDelegate=self;
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;

               default:
            break;
    }

}
//根据字体宽度让字体自适应大小
/*
- (void)setFontSizeThatFits:(UILabel*)label
{
    CGFloat fontSizeThatFits;
    [label.text sizeWithFont:label.font
                 minFontSize:12.0   //最小字体
              actualFontSize:&fontSizeThatFits
                    forWidth:label.bounds.size.width
               lineBreakMode:NSLineBreakByWordWrapping];
    label.font = [label.font fontWithSize:fontSizeThatFits];
}
*/
-(void)publishBtnCilked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary*firstClassInfo=[defaults objectForKey:@"firstClassInfo"];
    
    if(!firstClassInfo)
    {
        [SVProgressHUD showErrorWithStatus:@"请点击班级,然后点击'+'加入班级"];
    }
    else
    switch (btn.tag) {
        case 200:
        {
            XXYCoursewareController*publishCon=[[XXYCoursewareController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
        case 201:
        {
            XXYHomeworkController*publishCon=[[XXYHomeworkController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;

        case 202:
        {
            XXYScoreController*publishCon=[[XXYScoreController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;

        case 203:
        {
            XXYAnnouncementController*publishCon=[[XXYAnnouncementController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
