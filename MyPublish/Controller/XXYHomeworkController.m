#import "XXYHomeworkController.h"
#import "XXYBackButton.h"
#import "XXYPublishHomeworkController.h"
#import "XXYClassListController.h"
#import "BSHttpRequest.h"
#import "XXYHomeworkListModel.h"
#import "XXYHomeworkCell.h"
#import "MJRefresh.h"
#import "XXYCheckHomeworkController.h"

@interface XXYHomeworkController ()<XXYPublishContentTypeListDelegate,UITableViewDelegate,UITableViewDataSource,XXYReloadTableViewDelegate>
{
    NSInteger _currentPage;
}
@property(nonatomic,strong)UIButton*classBtn;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,copy) NSDictionary* firstClassDict;
@property(nonatomic,retain)NSMutableArray*dataCacheArray;
@property(nonatomic,strong)UIView*nothingView;

@end

@implementation XXYHomeworkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"已发布作业";
    self.view.backgroundColor=XXYBgColor;
    
    _currentPage=2;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _firstClassDict=[defaults objectForKey:@"firstClassInfo"];
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIButton*addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame=CGRectMake(0, 0, 30, 30);
    [addBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:addBtn];
    
    [self setUpClassBtn];
    [self.view addSubview:self.tableView];
    [self addRefreshLoadMore];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=XXYBgColor;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
        [self.tableView registerNib:[UINib nibWithNibName:@"XXYHomeworkCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
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
-(NSMutableArray*)dataCacheArray
{
    if(!_dataCacheArray)
    {
        _dataCacheArray=[NSMutableArray array];
    }
    return _dataCacheArray;
}
-(void)loadNewData
{
    _currentPage=2;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/homework/list"];
    if(_firstClassDict)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":_firstClassDict[@"id"],@"pageSize":@10} success:^(id responseObject){
       
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*array=objString[@"data"];
        
        if(array.count<=0)
        {
            [self setUpNoContentOfSubView:@"暂无作业内容"];
        }
        else
        {
            [_nothingView removeFromSuperview];
        }

        self.dataCacheArray=[NSMutableArray arrayWithArray:array];
         [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"homeworkList" WithPath:@"homeworkList.plist"];
        
        for (NSDictionary*dict in array)
        {
            XXYHomeworkListModel*model=[[XXYHomeworkListModel alloc]initWithDictionary:dict error:nil];
            [_dataList addObject:model];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
//        NSLog(@"%@",error.localizedDescription);
        [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"homeworkList" WithPath:@"homeworkList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYHomeworkListModel*model=[[XXYHomeworkListModel alloc]initWithDictionary:dict error:nil];
            [_dataList addObject:model];
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
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/homework/list"];

    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":_firstClassDict[@"id"],@"pageNum":page} success:^(id responseObject){
        
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
            XXYHomeworkListModel*model=[[XXYHomeworkListModel alloc]initWithDictionary:dict error:nil];
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
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10,50,MainScreenW-20, [XXYMyTools normalTableheight]-50) style:UITableViewStylePlain];
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

-(NSDictionary*)firstClassDict
{
    if(!_firstClassDict)
    {
       _firstClassDict=[NSDictionary dictionary];
    }
    return _firstClassDict;
}
-(void)setUpClassBtn
{
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 50)];
    label.textAlignment=NSTextAlignmentRight;
    label.text=@"班  级:";
    label.textColor=XXYCharactersColor;
    [bgView addSubview:label];
    
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
    [selBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    selBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    selBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [selBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    selBtn.tag=200;
    _classBtn=selBtn;
    [bgView addSubview:selBtn];
}
-(void)selBtnClicked:(UIButton*)btn
{
    XXYClassListController*classC=[[XXYClassListController alloc]init];
    classC.titleName=@"班级";
    classC.publishDelegate=self;
    classC.index=1;
    [self.navigationController pushViewController:classC animated:YES];
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
#pragma mark -tableViewDelegate

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        XXYPublishHomeworkController*detailCon=[[XXYPublishHomeworkController alloc]init];
        detailCon.homeworkModel=self.dataList[indexPath.section];
        detailCon.homeworkIndex=1;
        detailCon.reloadDelegate=self;
        detailCon.publishHomeworkTitle=@"修改已发布作业";
        [self.navigationController pushViewController:detailCon animated:YES];
        
    }];
    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[editRowAction];//最后返回这俩个RowAction 的数组
}
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
    XXYHomeworkCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.datamodel=self.dataList[indexPath.section];
    cell.layer.cornerRadius=5;
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYHomeworkListModel*model=self.dataList[indexPath.section];
    NSDictionary *attrDic=@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]};
    CGSize labelSize=[model.myDescription boundingRectWithSize:CGSizeMake(MainScreenW-130, MAXFLOAT)
                                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                        attributes:attrDic context:nil].size;
    
        return labelSize.height+95;
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
    XXYCheckHomeworkController*checkCon=[[XXYCheckHomeworkController alloc]init];
    checkCon.titleName=_firstClassDict[@"name"];
    XXYHomeworkListModel*model=self.dataList[indexPath.section];
    checkCon.homeworkId=[NSNumber numberWithInteger:model.uid];
    [self.navigationController pushViewControllerWithAnimation:checkCon];
}
-(void)publish:(UIBarButtonItem*)barItem
{
    XXYPublishHomeworkController*pubHomeworkC=[[XXYPublishHomeworkController alloc]init];
     pubHomeworkC.publishHomeworkTitle=@"发布作业";
    pubHomeworkC.reloadDelegate=self;
    [self.navigationController pushViewControllerWithAnimation:pubHomeworkC];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
