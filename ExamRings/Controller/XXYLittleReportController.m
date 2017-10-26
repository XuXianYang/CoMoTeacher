#import"BSHttpRequest.h"
#import "XXYBackButton.h"
#import "XXYLittleReportController.h"
#import "BSHttpRequest.h"
#import "MJRefresh.h"
#import "XXYLittleReportModel.h"
#import "XXYLittleReportCell.h"
@interface XXYLittleReportController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _currentPage;
}
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,retain)NSMutableArray*dataCacheArray;
@property(nonatomic,strong)UIView*nothingView;

@end

@implementation XXYLittleReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    self.navigationItem.title=@"小报告";
    _currentPage=2;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;

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
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
}
-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/sneaking/msg/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        
        [self.tableView.mj_footer endRefreshing];
//         NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        
        if(array.count>0)
        {
            _currentPage++;
            [self.dataCacheArray addObjectsFromArray:array];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"littleReportList" WithPath:@"littleReportList.plist"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"已经到底了~"];
        }

        for (NSDictionary*dict in array)
        {
            XXYLittleReportModel*model=[[XXYLittleReportModel alloc]initWithDictionary:dict error:nil];
            model.realName=dict[@"student"][@"realName"];
            model.className=dict[@"classInfo"][@"className"];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}
-(void)loadNewData
{
    _currentPage=2;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/sneaking/msg/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        if(array.count<=0)
        {
            [self setUpNoContentOfSubView:@"暂无报告内容"];
        }
        else
        {
            [_nothingView removeFromSuperview];
        }

        self.dataCacheArray=[NSMutableArray arrayWithArray:array];
         [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"littleReportList" WithPath:@"littleReportList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYLittleReportModel*model=[[XXYLittleReportModel alloc]initWithDictionary:dict error:nil];
            model.realName=dict[@"student"][@"realName"];
            model.className=dict[@"classInfo"][@"className"];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"littleReportList" WithPath:@"littleReportList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYLittleReportModel*model=[[XXYLittleReportModel alloc]initWithDictionary:dict error:nil];
            model.realName=dict[@"student"][@"realName"];
            model.className=dict[@"classInfo"][@"className"];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void)setUpNoContentOfSubView:(NSString*)title
{
    [_nothingView removeFromSuperview];
    
    CGFloat height=self.tableView.frame.size.height;
    CGFloat width=self.tableView.frame.size.width;
    
    _nothingView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [self.tableView addSubview:_nothingView];
    
    CGFloat hight=(height-width/2)/3;
    //320*260
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(width/4, hight, width/2,width/2)];
    imageView.image=[UIImage imageNamed:@"nocontent_bg"];
    [_nothingView addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, hight+width/2, width-100,50)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    label.font=[UIFont systemFontOfSize:16];
    label.text=title;
    [_nothingView addSubview:label];
}

-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=XXYBgColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYLittleReportCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
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
-(NSMutableArray*)dataCacheArray
{
    if(!_dataCacheArray)
    {
        _dataCacheArray=[NSMutableArray array];
    }
    return _dataCacheArray;
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
    XXYLittleReportCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.layer.cornerRadius=5;
    cell.index=indexPath.section%2;
    cell.backgroundColor=[UIColor clearColor];
    cell.dataModel=self.dataList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYLittleReportModel*model=self.dataList[indexPath.section];
    return [self turnCellHigh:model.content];
}
-(CGFloat)turnCellHigh:(NSString*)content
{
    NSMutableAttributedString *attibutesString = [[NSMutableAttributedString alloc]initWithString:content];
    NSMutableParagraphStyle *paraghStyle =[[NSMutableParagraphStyle alloc] init];
    [paraghStyle setLineSpacing:5];
    [paraghStyle setHeadIndent:10];
    [paraghStyle setFirstLineHeadIndent:10];
    [paraghStyle setMaximumLineHeight:25];
    [paraghStyle setMinimumLineHeight:5];
    [attibutesString addAttribute:NSParagraphStyleAttributeName value:paraghStyle range:NSMakeRange(0, content.length)];
    //在这传进去字体和行距
    NSDictionary *attribute =@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSParagraphStyleAttributeName:paraghStyle};
     CGSize labelSize=[content boundingRectWithSize:CGSizeMake(MainScreenW-20, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                              attributes:attribute context:nil].size;
    return labelSize.height+150;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-20, 30)];
    view.backgroundColor=XXYBgColor;
    return view;
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}

@end
