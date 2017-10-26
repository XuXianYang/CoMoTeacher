#import "XXYCheckHomeworkController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"
#import "XXYHomeworkListOfCheckModel.h"
#import "XXYHomeworkListOfCheckCell.h"
#import "MJRefresh.h"

@interface XXYCheckHomeworkController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;

@end

@implementation XXYCheckHomeworkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.titleName;
    self.view.backgroundColor=XXYBgColor;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpTableView];
    [self addRefreshLoadMore];
    //[self loadNewData];
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
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@%@",BaseUrl,@"/teacher/homework/reviewList/",self.homeworkId];
//    NSLog(@"11--%@",self.homeworkId);
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

        
        NSArray*array=objString[@"data"];
        
        for (NSDictionary*dict in array)
        {
            XXYHomeworkListOfCheckModel*model=[[XXYHomeworkListOfCheckModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
    
}

-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=XXYBgColor;
    //    self.tableView.bounces=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYHomeworkListOfCheckCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
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
    
    XXYHomeworkListOfCheckCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.layer.cornerRadius=5;
    cell.dataModel=self.dataList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYHomeworkListOfCheckModel*model=self.dataList[indexPath.section];
    NSString*textString=@"";
    if(model.isSign)
    {
        textString=[NSString stringWithFormat:@"%@在%@已阅",model.parentName,model.strReviewTime];
    }
    else
    {
        textString=@"暂无家长检查作业";
    }
    NSDictionary *attrDic=@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]};
    
    CGSize labelSize=[textString boundingRectWithSize:CGSizeMake(MainScreenW-155, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                    attributes:attrDic context:nil].size;
    return labelSize.height+50;
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
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
