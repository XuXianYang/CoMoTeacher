#import "XXYCoursewareController.h"
#import "XXYBackButton.h"
#import "XXYPublishCoursewareController.h"
#import "BSHttpRequest.h"
#import "XXYCourseWareListModel.h"
#import "XXYCourseWarelListCell.h"
#import "MJRefresh.h"
@interface XXYCoursewareController ()<UITableViewDelegate,UITableViewDataSource,XXYReloadTableViewDelegate>
{
    NSInteger _currentPage;
    
    UIAlertController *_alertCon;
}
@property(nonatomic,retain)NSMutableArray*dataCacheArray;

@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;

@property(nonatomic,strong)UIView*nothingView;

@end
@implementation XXYCoursewareController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"已发布课件";
    self.view.backgroundColor=XXYBgColor;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;

    _currentPage=1;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIButton*addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame=CGRectMake(0, 0, 30, 30);
    [addBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:addBtn];
    
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
-(void)reloadTableView
{
    [self loadNewData];
}
-(void)loadNewData
{
    _currentPage=2;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/material/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":@1,@"pageSize":@10} success:^(id responseObject){
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArr=objString[@"data"];
        
        if(dataArr.count<=0)
        {
            [self setUpNoContentOfSubView:@"暂无课件内容"];
        }
        else
        {
            [_nothingView removeFromSuperview];
        }
        self.dataCacheArray=[NSMutableArray arrayWithArray:dataArr];
        [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"courseWareListCache" WithPath:@"courseWareList.plist"];

        for (NSDictionary*dict in dataArr)
        {
            XXYCourseWareListModel*model=[[XXYCourseWareListModel alloc]initWithDictionary:dict error:nil];
            model.className=dict[@"classInfo"][@"className"];
            NSNumber* classid=dict[@"classInfo"][@"classId"];
            model.myDescription=dict[@"description"];
            model.classId=[classid integerValue];
            [_dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.dataList removeAllObjects];
         NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"courseWareListCache" WithPath:@"courseWareList.plist"];
        
        for (NSDictionary*dict in array)
        {
            XXYCourseWareListModel*model=[[XXYCourseWareListModel alloc]initWithDictionary:dict error:nil];
            model.className=dict[@"classInfo"][@"className"];
            NSNumber* classid=dict[@"classInfo"][@"classId"];
            model.myDescription=dict[@"description"];
            model.classId=[classid integerValue];
            [_dataList addObject:model];
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

-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/material/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":page} success:^(id responseObject){
        [self.tableView.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
           _currentPage++;
            [self.dataCacheArray addObjectsFromArray:dataArr];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"courseWareListCache" WithPath:@"courseWareList.plist"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"没有更多内容了"];
        }
        
        for (NSDictionary*dict in dataArr)
        {
            XXYCourseWareListModel*model=[[XXYCourseWareListModel alloc]initWithDictionary:dict error:nil];
            model.className=dict[@"classInfo"][@"className"];
            NSNumber* classid=dict[@"classInfo"][@"classId"];
            model.myDescription=dict[@"description"];
            model.classId=[classid integerValue];
            [_dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"没有更多内容了"];
        [self.tableView.mj_footer endRefreshing];
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
   [self.tableView registerNib:[UINib nibWithNibName:@"XXYCourseWarelListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10, 0, MainScreenW-20, [XXYMyTools normalTableheight]) style:UITableViewStylePlain];
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
       XXYCourseWarelListCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.dataModel=self.dataList[indexPath.section];
    cell.layer.cornerRadius=5;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XXYCourseWareListModel*model=self.dataList[indexPath.section];
    //文字
    CGFloat textMaxW = MainScreenW - 40;
    CGSize textMaxSize = CGSizeMake(textMaxW, MAXFLOAT);
    CGSize textSize = [model.myDescription boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
    CGFloat cellHeight = textSize.height + 65;
    
    return cellHeight;
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
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
        XXYCourseWareListModel*model=self.dataList[indexPath.section];
        NSNumber*coursewareId=[NSNumber numberWithInteger:model.uid];
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/courseware/remove"];

            [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"id":coursewareId} success:^(id responseObject){
                
                //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if([objString[@"message"] isEqualToString:@"success"])
                {
                    [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                    [self loadNewData];
                }
                else
                {
                    [SVProgressHUD showSuccessWithStatus:@"删除失败"];
                }
                
            } failure:^(NSError *error) {
                [SVProgressHUD showSuccessWithStatus:@"删除失败"];

            }];
    }];
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        XXYPublishCoursewareController*con=[[XXYPublishCoursewareController alloc]init];
        con.courseListModelIndex=1;
        XXYCourseWareListModel*model=self.dataList[indexPath.section];
        con.courseListModel=model;
        con.titleName=@"修改已发布课件";
        con.reloadDelegate=self;

        [self.navigationController pushViewController:con animated:YES];
    }];
    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    return @[deleteRoWAction, editRowAction];//最后返回这俩个RowAction 的数组
    
}
//-(void)setUpAlertController:(NSString*)str
//{
//    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [self loadNewData];
//    }];
//    [_alertCon addAction:action2];
//}
/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // 从锚点位置出发，逆时针绕 Y 和 Z 坐标轴旋转90度
    CATransform3D transform3D = CATransform3DMakeRotation(M_PI_2, 0.0, 1.0, 1.0);
    // 定义 cell 的初始状态
    cell.alpha = 0.0;
    cell.layer.transform = transform3D;
    cell.layer.anchorPoint = CGPointMake(0.0, 0.5);
    cell.layer.cornerRadius=5;
    [UIView animateWithDuration:0.5 animations:^{
        cell.alpha = 1.0;
        cell.layer.transform = CATransform3DIdentity;
        CGRect rect = cell.frame;
        rect.origin.x = 0.0;
        cell.frame = rect;
        cell.layer.cornerRadius=5;
    }];
}
 */
-(void)publish:(UIBarButtonItem*)barItem
{
    XXYPublishCoursewareController*pubCourseC=[[XXYPublishCoursewareController alloc]init];
    pubCourseC.titleName=@"发布课件";
    pubCourseC.reloadDelegate=self;
    [self.navigationController pushViewControllerWithAnimation:pubCourseC];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}

@end
