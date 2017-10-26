#import "XXYClassController.h"
#import "XXYClassListController.h"
#import "XXYAddClassController.h"
#import "YXScrollMenu.h"
#import "XXYClassroomTeachersModel.h"
#import "XXYClassroomTeachersCell.h"
#import "BSHttpRequest.h"
#import "MJRefresh.h"
#import "XXYStudentInfoListModel.h"
#import "XXYStudentIndoListCell.h"
#import "MQTitleButton.h"
#import "UIScrollView+XXYScrollview.h"
@interface XXYClassController ()<XXYSendClassDictDelegate,UIScrollViewDelegate,YXScrollMenuDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,XXYReloadNewDataDelegate>

@property(nonatomic,copy) NSDictionary* firstClassDict;
@property (nonatomic, weak) YXScrollMenu *menu;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger previousIndex;
@property(nonatomic,strong)UICollectionView*collectionView;
@property(nonatomic,retain)NSMutableArray*collectionDataList;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property (nonatomic, strong) MQTitleButton *classBtn;
@property (nonatomic, strong) UIView *animationView;
@property(nonatomic,strong)UIView*nothingView;
@property(nonatomic,strong)UIView*noTeacherView;

@property(nonatomic,assign)BOOL isNothingView;
@property(nonatomic,assign)BOOL isTeacherView;
@end

@implementation XXYClassController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _firstClassDict=[defaults objectForKey:@"firstClassInfo"];

    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    
    [self setupNavBar];
    [self setUpSubViews];
    [self setUpCollectionView];
    [self addRefreshLoadMore];
    [self setUpTableView];
    [self addTableViewRefreshLoadMore];
    [self loadClassInfo];
}
- (void)setupNavBar
{
    UIButton*addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame=CGRectMake(0, 0, 30, 30);
    [addBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addClassBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:addBtn];

    UIButton*navLabel=[UIButton buttonWithType:UIButtonTypeSystem];
    navLabel.frame=CGRectMake(0, 0, 60, 30);
    [navLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [navLabel setTitle:@"班级:" forState:UIControlStateNormal];
    navLabel.userInteractionEnabled=NO;
    navLabel.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:18];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:navLabel];
    
    // 设置导航栏中间的标题按钮
    MQTitleButton *titleButton = [[MQTitleButton alloc] init];
    // 设置尺寸
    titleButton.height = 35;
    // 设置文字
    NSString *name = @"";
    if(_firstClassDict)
    {
        name=_firstClassDict[@"name"];
    }
    else
    {
        name=@"请先加入班级";
    }

    [titleButton setTitle:name forState:UIControlStateNormal];
    // 设置图标
    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
    [titleButton setBackgroundColor:[UIColor colorWithRed:1.0/255 green:188.0/255 blue:181.0/255 alpha:1.0]];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    titleButton.titleLabel.font=[UIFont systemFontOfSize:15];
    titleButton.layer.cornerRadius=5;
    // 设置背景
    [titleButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    // 监听按钮点击
    [titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton;
    titleButton.tag=200;
    self.classBtn = titleButton;
}
-(void)titleClick:(UIButton*)btn
{
    XXYClassListController*classC=[[XXYClassListController alloc]init];
    classC.hidesBottomBarWhenPushed=YES;
    classC.titleName=@"班级";
    classC.sendClassInfoDictDelegate=self;
    classC.index=1;
    [self.navigationController pushViewControllerWithAnimation:classC];
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(void)addTableViewRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadTableViewNewData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;

}
-(void)loadTableViewNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/student/list"];
    if(_firstClassDict)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":_firstClassDict[@"id"]} success:^(id responseObject){
        
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*array=objString[@"data"];
        if(array.count<=0)
        {
            if(!_isNothingView)
            {
                _isNothingView=1;
                [self setUpNoContentOfSubView:@"暂无学生加入班级" AndView:self.tableView AndSuperView:_nothingView];
            }
        }
        else
        {
            [_nothingView removeFromSuperview];
        }

        [BSHttpRequest archiverObject:array ByKey:@"studentInfoList" WithPath:@"studentInfoList.plist"];
        [self turnTableViewDataToModel:array];
        
            } failure:^(NSError *error) {
                
                [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"studentInfoList" WithPath:@"studentInfoList.plist"];
        
                [self turnTableViewDataToModel:array];
                
        [self.tableView.mj_header endRefreshing];
    }];
    else
    {
        if(!_isNothingView)
        {
            _isNothingView=1;
            [self setUpNoContentOfSubView:@"暂无学生加入班级" AndView:self.tableView AndSuperView:_nothingView];
        }
        
        [self.tableView.mj_header endRefreshing];
    }
}
-(void)setUpNoContentOfSubView:(NSString*)title AndView:(UIView*)view AndSuperView:(UIView*)superView
{
    
    CGFloat height=view.frame.size.height;
    CGFloat width=view.frame.size.width;
    
    superView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [view addSubview:superView];
    
    CGFloat hight=(height-width/2)/3;
    //320*260
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(width/4, hight, width/2,width/2)];
    imageView.image=[UIImage imageNamed:@"nocontent_bg"];
    [superView addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, hight+width/2, width-100,50)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    label.font=[UIFont systemFontOfSize:16];
    label.text=title;
    [superView addSubview:label];
}

-(void)turnTableViewDataToModel:(NSArray*)array
{
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
                    parentName=[NSString stringWithFormat:@"%@ %@",parentInfoDict[@"realName"],parentName];
                else
                    parentName=@"暂无";
                if(parentInfoDict[@"mobileNo"])
                {
                    parentNo=[NSString stringWithFormat:@"%@ %@",parentInfoDict[@"mobileNo"],parentNo];
                }
                else
                {
                    parentNo=@"暂无";
                }
            }
            model.parentName=parentName;
            model.parentMobileNo=parentNo;
        }
        [self.dataList addObject:model];
    }
    [self.tableView reloadData];
}

-(void)setUpTableView
{
    [_scrollView addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=XXYBgColor;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYStudentIndoListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"tableViewCellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10, 0, MainScreenW-20, MainScreenH-64-49-47) style:UITableViewStylePlain];
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
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}
//-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//        
//        
//    }];
//    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
//    return @[editRowAction];//最后返回这俩个RowAction 的数组
//}
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
    XXYStudentIndoListCell*cell=[tableView dequeueReusableCellWithIdentifier:@"tableViewCellId" forIndexPath:indexPath];
    cell.dataModel=self.dataList[indexPath.section];
    cell.layer.cornerRadius=5;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self alertOfDeleteStudentClick:indexPath.section];
}
-(void)alertOfDeleteStudentClick:(NSInteger)index
{
    
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要删除该学生吗?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [action1 setValue:[UIColor colorWithRed:10.0/255 green:188.0/255 blue:180.0/255 alpha:1] forKey:@"titleTextColor"];
    [alertCon addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteStudent:index];
    }];
    [action2 setValue:[UIColor colorWithRed:10.0/255 green:188.0/255 blue:180.0/255 alpha:1] forKey:@"titleTextColor"];
    [alertCon addAction:action2];
    [self presentViewController:alertCon animated:YES completion:nil];
}
-(void)deleteStudent:(NSInteger)index
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    XXYStudentInfoListModel*model=self.dataList[index];
    NSNumber*studentId=[NSNumber numberWithInteger:model.studentId];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/student/remove"];
    if(_firstClassDict)
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":_firstClassDict[@"id"],@"studentId":studentId} success:^(id responseObject){
            
            //            NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [self loadTableViewNewData];
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"删除失败"];
                
            }
        } failure:^(NSError *error) {
            [SVProgressHUD showSuccessWithStatus:@"删除失败"];
        }];
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-20, 10)];
    view.backgroundColor=XXYBgColor;
    return view;
}
//添加刷新加载更多
- (void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.collectionView.mj_header = header;
}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/course/assignment"];
    if(_firstClassDict)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"enrolYear":_firstClassDict[@"enrolYear"],@"classNumber":_firstClassDict[@"classNumber"]} success:^(id responseObject){
        
        [self.collectionView.mj_header endRefreshing];
        //先清空数据源
        [self.collectionDataList removeAllObjects];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        
        [BSHttpRequest archiverObject:array ByKey:@"teacherInfoList" WithPath:@"teacherInfoList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYClassroomTeachersModel*model=[[XXYClassroomTeachersModel alloc]initWithDictionary:dict error:nil];
            [self.collectionDataList addObject:model];
        }
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        
        [self.collectionDataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"teacherInfoList" WithPath:@"teacherInfoList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYClassroomTeachersModel*model=[[XXYClassroomTeachersModel alloc]initWithDictionary:dict error:nil];
            [self.collectionDataList addObject:model];
        }
        [self.collectionView reloadData];
        
        
        [self.collectionView.mj_header endRefreshing];
    }];
    else
    {
        if(!_isTeacherView)
        {
            _isTeacherView=1;
           [self setUpNoContentOfSubView:@"暂无老师加入班级" AndView:self.collectionView AndSuperView:_noTeacherView];
        }
        [self.collectionView.mj_header endRefreshing];
    }
}
-(void)setUpCollectionView
{
    UICollectionViewFlowLayout*layout=[[UICollectionViewFlowLayout alloc]init];
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(MainScreenW, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) collectionViewLayout:layout];
    [_scrollView addSubview:_collectionView];
    _collectionView.bounces=YES;
    _collectionView.showsVerticalScrollIndicator=NO;
    //设置代理
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    _collectionView.backgroundColor=XXYBgColor;
    //注册
    [self.collectionView registerNib:[UINib nibWithNibName:@"XXYClassroomTeachersCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellId"];
}
//数据源
-(NSMutableArray*)collectionDataList
{
    if(!_collectionDataList)
    {
        _collectionDataList=[NSMutableArray array];
    }
    return _collectionDataList;
}

#pragma mark -----delegate------
//每个分区cell个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionDataList.count;
}
//建立cell
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XXYClassroomTeachersCell*cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.dataModel=self.collectionDataList[indexPath.item];
    cell.layer.cornerRadius=5;
    cell.backgroundColor=[UIColor whiteColor];
    return cell;
}
//每个item的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((MainScreenW-30)/2, 80);
}
//布局时每个collectionViewLayout距离屏幕四周最小的距离
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
//每个item横向最小间隔
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
//每个item竖向最小间隔
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    XXYClassroomTeachersModel*model=self.dataList[indexPath.item];
//    if(model.teacherMobile)
//    {
//        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",model.teacherMobile];
//        UIWebView * callWebview = [[UIWebView alloc] init];
//        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//        [self.view addSubview:callWebview];
//    }
}
-(void)selBtnClicked:(UIButton*)btn
{
    XXYClassListController*classC=[[XXYClassListController alloc]init];
    classC.hidesBottomBarWhenPushed=YES;
    classC.titleName=@"班级";
    classC.sendClassInfoDictDelegate=self;
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
-(void)reloadNewClassData
{
    [self getFirstClassInfo];
}
//加入班级成功之后缓存已经加入班级信息
-(void)getFirstClassInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray*array=objString[@"data"];
            if(array.count>0)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:array[0] forKey:@"firstClassInfo"];
                [defaults setObject:array forKey:@"teacherClassList"];
                
                _firstClassDict=array[array.count-1] ;
                [_classBtn setTitle:_firstClassDict[@"name"] forState:UIControlStateNormal];
                [self loadTableViewNewData];
                [self loadNewData];
                [self loadClassInfo];
            }
        } failure:^(NSError *error) {
        }];
}
-(void)sendClassInfoDict:(NSDictionary *)dict andIndex:(NSInteger)index
{
    if(index==1)
    {
        [_classBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
        _firstClassDict=dict;
        [self loadTableViewNewData];
        [self loadNewData];
        [self loadClassInfo];
    }
}
-(void)addClassBtnClicked:(UIBarButtonItem*)barItem
{
    XXYAddClassController*addC=[[XXYAddClassController alloc]init];
    addC.reloadDelegate=self;
    addC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:addC animated:YES];
}
-(void)setUpSubViews
{
    YXScrollMenu *menu = [[YXScrollMenu alloc] initWithFrame:CGRectMake(0,0,MainScreenW, 45)];
    menu.backgroundColor=[UIColor whiteColor];
    menu.titleArray = @[@"我的学生", @"任课老师",@"班级管理"];
    menu.cellWidth =MainScreenW/3;
    menu.delegate = self;
    menu.isHiddenSeparator = YES;
    menu.selectedTextColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
    menu.normalBackgroundColor=[UIColor whiteColor];
    menu.selectedBackgroundColor=[UIColor whiteColor];
    [self.view addSubview:menu];
    _menu = menu;
    
    _animationView=[[UIView alloc]initWithFrame:CGRectMake(0, 45, MainScreenW/3, 4)];
    _animationView .backgroundColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
    [self.view addSubview:_animationView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 47, MainScreenW, MainScreenH - 64-49-47)];
    //回弹
    scrollView.bounces=NO;
    //分页
    scrollView.backgroundColor=XXYBgColor;
    scrollView.pagingEnabled = YES;
    //横向滚动条
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.contentSize = CGSizeMake(menu.titleArray.count * MainScreenW, 0);
    scrollView.delegate = self;
    scrollView.scrollEnabled=YES;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
    UIImageView*schoolIcon=[[UIImageView alloc]initWithFrame:CGRectMake(MainScreenW*2+15, 15, MainScreenW-30, (MainScreenW-30)*170/345)];
    schoolIcon.image=[UIImage imageNamed:@"img_shool_info"];
    [_scrollView addSubview:schoolIcon];
    
    UIView*classInfoBgView=[[UIView alloc]initWithFrame:CGRectMake(MainScreenW*2+15,(MainScreenW-30)*170/345+15, MainScreenW-30, _scrollView.frame.size.height-(MainScreenW-30)*170/345-45)];
    classInfoBgView.backgroundColor=[UIColor whiteColor];
    
    //上面两个设置为圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:classInfoBgView.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = classInfoBgView.bounds;
    maskLayer.path = maskPath.CGPath;
    classInfoBgView.layer.mask = maskLayer;

    [_scrollView addSubview:classInfoBgView];
    
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};
    CGSize size=[@"所属学校: 上海市第一虚拟中学" sizeWithAttributes:attrs];
    CGFloat labelWidth=size.width;
    
    for(int i=0;i<5;i++)
    {
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake((MainScreenW-30-labelWidth)/2, i*35+20, labelWidth+(MainScreenW-30-labelWidth)/2, 35)];
        label.tag=100+i;
        label.textColor=XXYCharactersColor;
        [classInfoBgView addSubview:label];
    }
}
-(void)loadClassInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/detail"];
    if(_firstClassDict)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":_firstClassDict[@"id"]} success:^(id responseObject){
        
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
       NSString* schoolName=[NSString stringWithFormat:@"所属学校: %@",objString[@"data"][@"schoolInfo"][@"name"]];
       NSString*schoolCode=[NSString stringWithFormat:@"学校编码: %@",objString[@"data"][@"schoolInfo"][@"code"]];
        NSString*enroYear=[NSString stringWithFormat:@"所属学年: %@",objString[@"data"][@"basicInfo"][@"enrolYear"]];
        NSString*classCode=[NSString stringWithFormat:@"班级编码: %@",objString[@"data"][@"basicInfo"][@"code"]];
        NSString*masterTeacher;
        if(objString[@"data"][@"headTeacher"][@"realName"])
        {
           masterTeacher=[NSString stringWithFormat:@"班 主 任 : %@",objString[@"data"][@"headTeacher"][@"realName"]];
        }
        else
        {
            masterTeacher=@"班 主 任 : 暂无姓名";
        }
        
        NSArray*array=@[schoolName,schoolCode,enroYear,classCode,masterTeacher];
        
        [BSHttpRequest archiverObject:array ByKey:@"classInfoData" WithPath:@"classInfoData.plist"];
        
        for(int i=0;i<5;i++)
        {
            UILabel*label=[self.view viewWithTag:100+i];
            label.text=array[i];
        }
    } failure:^(NSError *error) {
        
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"classInfoData" WithPath:@"classInfoData.plist"];
        for(int i=0;i<5;i++)
        {
            UILabel*label=[self.view viewWithTag:100+i];
            label.text=array[i];
        }
    }];
}
#pragma mark - YXScrollMenu delgate
- (void)scrollMenu:(YXScrollMenu *)scrollMenu selectedIndex:(NSInteger)selectedIndex
{
    [UIView animateWithDuration:0.2 * ABS(selectedIndex - _previousIndex)   animations:^{
        _scrollView.contentOffset = CGPointMake(selectedIndex * MainScreenW, 0);
        _animationView.frame=CGRectMake(selectedIndex*MainScreenW/3,45, MainScreenW/3, 4);
    }];
}
#pragma mark - UIScrollView delegate

//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(scrollView==_scrollView)
    {
        _menu.currentIndex = scrollView.contentOffset.x / MainScreenW;
        
        [UIView animateWithDuration:0.2    animations:^{
            _animationView.frame=CGRectMake(_menu.currentIndex*MainScreenW/3,45, MainScreenW/3, 4);
        }];
    }
    
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        
        if(scrollView==_scrollView)
        {
            _menu.currentIndex = scrollView.contentOffset.x / MainScreenW;
            [UIView animateWithDuration:0.2  animations:^{
                
                _animationView.frame=CGRectMake(_menu.currentIndex*MainScreenW/3,45, MainScreenW/3, 4);
            }];

        }
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
