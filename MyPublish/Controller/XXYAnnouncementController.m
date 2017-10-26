#import "XXYAnnouncementController.h"
#import "XXYBackButton.h"
#import "XXYPublishAnnouncementController.h"
#import"XXYClassListController.h"
#import "BSHttpRequest.h"
#import "XXYAnnouncementCell.h"
#import "XXYAnnouncemmentLIstModel.h"
#import "MJRefresh.h"

@interface XXYAnnouncementController ()<XXYPublishContentTypeListDelegate,UITableViewDelegate,UITableViewDataSource,XXYReloadTableViewDelegate>
{
    NSInteger _currentPage;
}

@property(nonatomic,strong)UIButton*classBtn;
@property(nonatomic,copy) NSDictionary* firstClassDict;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,retain)NSMutableArray*dataCacheArray;
@property(nonatomic,strong)UIView*nothingView;

@end

@implementation XXYAnnouncementController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"班级公告";
    self.view.backgroundColor=XXYBgColor;
    _currentPage=2;
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _firstClassDict=[defaults objectForKey:@"firstClassInfo"];
//    NSLog(@"%@",_firstClassDict);
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIButton*addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame=CGRectMake(0, 0, 30, 30);
    [addBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:addBtn];
    
    [self setUpClassBtn];
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
-(void)loadNewData
{
     _currentPage=2;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*urslSring=[NSString stringWithFormat:@"%@/teacher/announcement/list?classId=%@&pageNum=1&pageSize=10",BaseUrl,_firstClassDict[@"id"]];
    
    if(_firstClassDict[@"id"])
    [BSHttpRequest POST:urslSring parameters:@{@"sid":userSidString} success:^(id responseObject){
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*array=objString[@"data"];
        
        if(array.count<=0)
        {
            [self setUpNoContentOfSubView:@"暂无公告内容"];
        }
        else
        {
            [_nothingView removeFromSuperview];
        }

        self.dataCacheArray=[NSMutableArray arrayWithArray:array];
        [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"classAnnourcementList" WithPath:@"classAnnourcementList.plist"];
        
        for (NSDictionary*dict in array)
        {
            XXYAnnouncemmentLIstModel*model=[[XXYAnnouncemmentLIstModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"classAnnourcementList" WithPath:@"classAnnourcementList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYAnnouncemmentLIstModel*model=[[XXYAnnouncemmentLIstModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
    else
    {
       [self.tableView.mj_header endRefreshing];
    }
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

-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    NSString*urslSring=[NSString stringWithFormat:@"%@/teacher/announcement/list?classId=%@&pageNum=%@&pageSize=10",BaseUrl,page,_firstClassDict[@"id"]];
    [BSHttpRequest POST:urslSring parameters:@{@"sid":userSidString} success:^(id responseObject){
        [self.tableView.mj_footer endRefreshing];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
            _currentPage++;
            
            [self.dataCacheArray addObjectsFromArray:dataArr];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"annourcementDataCache" WithPath:@"annourcementData.plist"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"已经到底了~"];
            
        }
        for (NSDictionary*dict in dataArr)
        {
            XXYAnnouncemmentLIstModel*model=[[XXYAnnouncemmentLIstModel alloc]initWithDictionary:dict error:nil];
            [_dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"已经到底了~"];
        [self.tableView.mj_footer endRefreshing];
    }];
    
}
-(void)reloadTableView
{
    [self loadNewData];
}
-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=XXYBgColor;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYAnnouncementCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10,50,MainScreenW-20, [XXYMyTools normalTableheight]-50) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray*)dataCacheArray
{
    if(!_dataCacheArray)
    {
        _dataCacheArray=[NSMutableArray array];
    }
    return _dataCacheArray;
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
    XXYAnnouncementCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.layer.cornerRadius=5;
    cell.datamodel=self.dataList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYAnnouncemmentLIstModel*model=self.dataList[indexPath.section];
    NSDictionary *attrDic=@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]};
    CGSize labelSize=[model.content boundingRectWithSize:CGSizeMake(MainScreenW-130, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
    
                                        attributes:attrDic context:nil].size;
    return labelSize.height+75;
    
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
    XXYPublishAnnouncementController*detailCon=[[XXYPublishAnnouncementController alloc]init];
    detailCon.announcemmentModel=self.dataList[indexPath.section];
    detailCon.announcemmentIndex=1;
    detailCon.reloadDelegate=self;
    detailCon.publishAnnouncemmentTitle=@"修改已发布公告";
    detailCon.classBtnName=self.firstClassDict[@"name"];
    [self.navigationController pushViewController:detailCon animated:YES];
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
    [self.view addSubview:label];
    
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
    [self.view addSubview:selBtn];
}
-(void)selBtnClicked:(UIButton*)btn
{
    XXYClassListController*classC=[[XXYClassListController alloc]init];
    classC.titleName=@"班级";
    classC.publishDelegate=self;
    classC.index=1;
    [self.navigationController pushViewController:classC animated:YES];
}
-(NSDictionary*)firstClassDict
{
    if(!_firstClassDict)
    {
        _firstClassDict=[NSDictionary dictionary];
    }
    return _firstClassDict;
}
-(void)sendPublishTypeName:(NSString *)title andIndex:(NSInteger)index andtypeId:(NSNumber *)typeId
{
    if(index==1)
    {
        [_classBtn setTitle:title forState:UIControlStateNormal];
        _firstClassDict=@{@"name":title,@"id":typeId};
        [self loadNewData];
    }
}

-(void)publish:(UIBarButtonItem*)barItem
{
    XXYPublishAnnouncementController*pubAC=[[XXYPublishAnnouncementController alloc]init];
    pubAC.publishAnnouncemmentTitle=@"发布公告";
    pubAC.reloadDelegate=self;
    [self.navigationController pushViewControllerWithAnimation:pubAC];
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
