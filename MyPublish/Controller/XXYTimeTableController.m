#import "XXYTimeTableController.h"
#import "XXYBackButton.h"
#import "XXYClassListController.h"
#import"YXScrollMenu.h"
#import "XXYTimeTableView.h"
#import "XXYCourseListController.h"
#import "XXYTimeTableModel.h"

@interface XXYTimeTableController ()<YXScrollMenuDelegate, UIScrollViewDelegate,XXYturnNextControllerDelegate,XXYPublishContentTypeListDelegate,XXYReloadTableViewDelegate>

@property(nonatomic,strong)UIButton*classBtn;
@property (nonatomic, weak) YXScrollMenu *menu;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger previousIndex;
@property(nonatomic,copy) NSDictionary* firstClassDict;
@property(nonatomic,strong) NSNumber* classId;

@end

@implementation XXYTimeTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"课程表";
    self.view.backgroundColor=XXYBgColor;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _firstClassDict=[defaults objectForKey:@"firstClassInfo"];
    _classId=_firstClassDict[@"id"];
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpClassBtn];
    [self setUpSubViews];
    [self setUpSubTabViews];
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(void)setUpSubTabViews
{
    for(int i=0;i<5;i++)
    {
        XXYTimeTableView*timeTableView= [XXYTimeTableView contentTableView];
        timeTableView.frame=CGRectMake(_scrollView.frame.size.width*i+10, 0, _scrollView.frame.size.width-20, _scrollView.frame.size.height-10);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        timeTableView.firstClassDict=[defaults objectForKey:@"firstClassInfo"];
        timeTableView.turnNextControllerDelegate=self;
        timeTableView.bounces=NO;
        timeTableView.index=i+1;
        timeTableView.tag=i+1;
        timeTableView.showsVerticalScrollIndicator=NO;
        [timeTableView addRefreshLoadMore];
        [_scrollView addSubview:timeTableView];
    }
}
-(void)turnNextController:(NSNumber *)lessonOfDay And:(NSNumber *)dayOfWeek
{
    XXYCourseListController*con=[[XXYCourseListController alloc]init];
    con.reloadDelegate=self;
    con.classId=_classId;
    con.lessonOfDay=lessonOfDay;
    con.dayOfWeek=dayOfWeek;
    [self.navigationController pushViewController:con animated:YES];
}
-(void)reloadTableView
{
    for(int i=0;i<5;i++)
    {
        XXYTimeTableView*tableView=[self.view viewWithTag:i+1];
        [tableView addRefreshLoadMore];
    }
}
-(void)setUpClassBtn
{
    UIView*titleBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    titleBgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:titleBgView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 50)];
    label.textAlignment=NSTextAlignmentRight;
    label.text=@"班  级:";
    label.textColor=XXYCharactersColor;
    [titleBgView addSubview:label];

    UIButton*selBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    selBtn.frame=CGRectMake(65, 10, MainScreenW-75, 30);
    selBtn.layer.cornerRadius=5;
    if(_firstClassDict)
    {
        [selBtn setTitle:_firstClassDict[@"name"] forState:UIControlStateNormal];
    }
    else
    {
        [selBtn setTitle:@"请先加入班级" forState:UIControlStateNormal];
    }
    [selBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    [selBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    selBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    selBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    selBtn.tag=200;
    _classBtn=selBtn;
    [titleBgView addSubview:selBtn];
}
-(void)selBtnClicked:(UIButton*)btn
{
    
    XXYClassListController*classC=[[XXYClassListController alloc]init];
        classC.titleName=@"班级";
        classC.publishDelegate=self;
        classC.index=1;
        [self.navigationController pushViewControllerWithAnimation:classC];
}
-(void)sendPublishTypeName:(NSString *)title andIndex:(NSInteger)index andtypeId:(NSNumber *)typeId
{
    if(index==1)
    {
        [_classBtn setTitle:title forState:UIControlStateNormal];
        _classId=typeId;
        
        for(int i=0;i<5;i++)
        {
            XXYTimeTableView*tableView=[self.view viewWithTag:i+1];
            
            tableView.firstClassDict=@{@"name":title,@"id":typeId};
            
            [tableView addRefreshLoadMore];
        }
    }
}
-(void)setUpSubViews
{
    YXScrollMenu *menu = [[YXScrollMenu alloc] initWithFrame:CGRectMake(15,65,MainScreenW-30, 40)];
    menu.backgroundColor=[UIColor whiteColor];
    menu.titleArray = @[@"星期一", @"星期二", @"星期三",@"星期四",@"星期五"];
    menu.cellWidth =(MainScreenW-30)/5;
    menu.delegate = self;
    menu.isHiddenSeparator = YES;
    menu.selectedTextColor=[UIColor whiteColor];
    menu.normalBackgroundColor=[UIColor whiteColor];
    menu.selectedBackgroundColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
    [self.view addSubview:menu];
    _menu = menu;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 120, MainScreenW-30, MainScreenH - 120-64-15)];
    scrollView.backgroundColor=[UIColor whiteColor];
    //回弹
    scrollView.bounces=NO;
    //分页
    scrollView.pagingEnabled = YES;
    //横向滚动条
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.contentSize = CGSizeMake(menu.titleArray.count * (MainScreenW-30), 0);
    scrollView.delegate = self;
    scrollView.scrollEnabled=YES;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
}
#pragma mark - YXScrollMenu delgate
- (void)scrollMenu:(YXScrollMenu *)scrollMenu selectedIndex:(NSInteger)selectedIndex
{
    [UIView animateWithDuration:0.2 * ABS(selectedIndex - _previousIndex)   animations:^{
        _scrollView.contentOffset = CGPointMake(selectedIndex * (MainScreenW-30), 0);
    }];
    _previousIndex = selectedIndex;
}
#pragma mark - UIScrollView delegate
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _menu.currentIndex = scrollView.contentOffset.x / (MainScreenW-30);
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        _menu.currentIndex = scrollView.contentOffset.x / (MainScreenW-30);
    }
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
@end
