#import "XXYPublishScoreController.h"
#import "XXYBackButton.h"
#import "MJRefresh.h"
#import "BSHttpRequest.h"
#import "XXYSctudentScoreCell.h"
#import "XXYStudentInfoListModel.h"
#import "XXYScoreSettingController.h"

@interface XXYPublishScoreController ()<UITableViewDelegate,UITableViewDataSource,XXYReloadTableViewDelegate>
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;

@end
@implementation XXYPublishScoreController
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor=XXYBgColor;
    self.navigationItem.title=self.quizInfoModel.courseName;

    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpTableView];
    [self addRefreshLoadMore];
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

//添加刷新加载更多
- (void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/student/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":self.classId} success:^(id responseObject){
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        for (NSDictionary*dict in array)
        {
            XXYStudentInfoListModel*model=[[XXYStudentInfoListModel alloc]initWithDictionary:dict error:nil];
            NSArray*parentsInfo=dict[@"parents"];
            if(parentsInfo)
            {
                NSString*parentNo=@"";
                NSString*parentName=@"";
                for (NSDictionary*parentInfoDict in parentsInfo)
                {
                    if(parentInfoDict[@"realName"])
                        parentName=[NSString stringWithFormat:@"%@%@",parentName,parentInfoDict[@"realName"]];
                    else
                        parentName=@"-";
                    parentNo=[NSString stringWithFormat:@"%@  %@",parentNo,parentInfoDict[@"mobileNo"]];
                }
                model.parentName=parentName;
                model.parentMobileNo=parentNo;
            }            
            [self.dataList addObject:model];
        }
        [self getScoreOfStudentOfOneClass];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void)getScoreOfStudentOfOneClass
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/quiz/score/all"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":self.classId,@"quizId":[NSNumber numberWithInteger:self.quizInfoModel.uid]} success:^(id responseObject){
        
        // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if(objString[@"data"]&&self.dataList)
        {
            for (NSDictionary*dict in objString[@"data"])
            {
                    for (XXYStudentInfoListModel*model in self.dataList)
                    {
                        if([[NSString stringWithFormat:@"%@",dict[@"studentId"]] isEqualToString:[NSString stringWithFormat:@"%i",model.studentId]])
                        {
                               model.stuScore=[NSString stringWithFormat:@"%@",dict[@"score"]];
                        }
                    }
            }
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
    }];
}
-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=XXYBgColor;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYSctudentScoreCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10, 0, MainScreenW-20, [XXYMyTools normalTableheight]) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
    }
    return _dataList;
}
#pragma mark -tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYSctudentScoreCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.dataModel=self.dataList[indexPath.section];
    cell.layer.cornerRadius=5;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.studentScore.tag=indexPath.section+1;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-20, 10)];
    view.backgroundColor=XXYBgColor;
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYScoreSettingController*scoreCon=[[XXYScoreSettingController alloc]init];
    XXYStudentInfoListModel*model=self.dataList[indexPath.section];
    scoreCon.titleName=model.realName;
    scoreCon.studentScore=model.stuScore;
    scoreCon.classId=self.classId;
    scoreCon.reloadDelegate=self;
    scoreCon.studentId=[NSString stringWithFormat:@"%i",model.studentId];
    scoreCon.quizId=[NSNumber numberWithInteger:self.quizInfoModel.uid];
    [self.navigationController pushViewControllerWithAnimation:scoreCon];
}
-(void)reloadTableView
{
    [self loadNewData];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
