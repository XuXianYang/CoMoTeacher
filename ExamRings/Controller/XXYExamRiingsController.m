#import "XXYExamRiingsController.h"
#import"XXYBackButton.h"
#import "BSHttpRequest.h"
#import "MJRefresh.h"
#import "XXYExamRingsCell.h"
#import "XXYExamContentModel.h"
#import "XXYClassListController.h"
#import "XXYTitleBtn.h"
@interface XXYExamRiingsController ()<UITableViewDelegate,UITableViewDataSource,XXYSendClassDictDelegate,XXYPublishContentTypeListDelegate>

@property(nonatomic,strong)UIButton*classBtn;
@property(nonatomic,strong)UIButton*courseBtn;
@property(nonatomic,copy) NSDictionary* firstClassDict;
@property(nonatomic,copy) NSDictionary* firstClassOfFirstCourseDict;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIView*nothingView;

@end

@implementation XXYExamRiingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    self.navigationItem.title=@"考试铃";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _firstClassDict=[defaults objectForKey:@"firstClassInfo"];
    
    if(_firstClassDict)
    {
        [self getUpCourseId:_firstClassDict[@"id"]];
        
    }

    
//    [self getUpCourseId:_firstClassDict[@"id"]];
//    _firstClassOfFirstCourseDict=[defaults objectForKey:@"courseIdOfClass"];
    
   // NSLog(@"%@",_firstClassOfFirstCourseDict);

    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    [self setUpSubViews];
     [self setUpTableView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(NSDictionary*)firstClassDict
{
    if(!_firstClassDict)
    {
        _firstClassDict=[NSDictionary dictionary];
    }
    return _firstClassDict;
}
-(NSDictionary*)firstClassOfFirstCourseDict
{
    if(!_firstClassOfFirstCourseDict)
    {
        _firstClassOfFirstCourseDict=[NSDictionary dictionary];
    }
    return _firstClassOfFirstCourseDict;
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
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/quiz/listByCourse"];
    
    if(_firstClassOfFirstCourseDict&&_firstClassDict)
        
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":_firstClassDict[@"id"],@"courseId":_firstClassOfFirstCourseDict[@"id"]} success:^(id responseObject){
        
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*array=objString[@"data"];
        if(array.count<=0)
        {
            [self setUpNoContentOfSubView:@"暂无考试内容"];
        }
        else
        {
            [_nothingView removeFromSuperview];
        }

        [BSHttpRequest archiverObject:array ByKey:@"testRingsList" WithPath:@"testRingsList.plist"];
        
        for (NSDictionary*dict in array)
        {
            XXYExamContentModel*model=[[XXYExamContentModel alloc]initWithDictionary:dict[@"quiz"] error:nil];
            model.courseName=dict[@"course"][@"name"];
            
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"testRingsList" WithPath:@"testRingsList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYExamContentModel*model=[[XXYExamContentModel alloc]initWithDictionary:dict[@"quiz"] error:nil];
            model.courseName=dict[@"course"][@"name"];
            
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

-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=XXYBgColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYExamRingsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
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
    XXYExamRingsCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.layer.cornerRadius=5;
    cell.dataModel=self.dataList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYExamContentModel*model=self.dataList[indexPath.section];
    NSDictionary *attrDic=@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]};
    CGSize labelSize=[model.myDescription boundingRectWithSize:CGSizeMake(MainScreenW-130, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                    attributes:attrDic context:nil].size;
    
    if(model.myDescription.length<1)
    {
        return 115;
    }
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
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)setUpSubViews
{
    UIView*titleBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    titleBgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:titleBgView];

    for(int i=0;i<2;i++)
    {
        XXYTitleBtn *titleButton = [[XXYTitleBtn alloc]init];
        titleButton.frame=CGRectMake(10+MainScreenW/2*i, 10, MainScreenW/2-20, 30);
        // 设置图标
        [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
        
        [titleButton setBackgroundColor:[UIColor colorWithRed:1.0/255 green:188.0/255 blue:181.0/255 alpha:1.0]];
        [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        titleButton.titleLabel.font=[UIFont systemFontOfSize:17];
        titleButton.layer.cornerRadius=5;
        // 监听按钮点击
        [titleButton addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        titleButton.tag=1+i;
        switch (i)
        {
            case 0:
            {
                if(_firstClassDict)
                {
                    [titleButton setTitle:_firstClassDict[@"name"] forState:UIControlStateNormal];
                }
                else
                {
                    [titleButton setTitle:@"请先加入班级" forState:UIControlStateNormal];
                }
                _classBtn=titleButton;
            }
                break;
            case 1:
            {
                if(_firstClassOfFirstCourseDict)
                {
                    [titleButton setTitle:_firstClassOfFirstCourseDict[@"name"] forState:UIControlStateNormal];
                }
                else
                {
                    [titleButton setTitle:@"暂无"forState:UIControlStateNormal];
                }
                _courseBtn=titleButton;
            }
                break;
            default:
                break;
        }
        
        [titleBgView addSubview:titleButton];
    }
}

//获取一个老师在指定的班级中所任教的课程列表(第一门课)
-(void)getUpCourseId:(NSNumber*)classId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/course/list"];

    _firstClassOfFirstCourseDict=[defaults objectForKey:@"courseIdOfClass"];
    NSString*name=_firstClassOfFirstCourseDict[@"name"];
    if(name.length==0&&classId)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":classId} success:^(id responseObject){
        
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        if(array.count>0)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:array[0] forKey:@"courseIdOfClass"];
            
            NSDictionary*dict=array[0];
            _firstClassOfFirstCourseDict=array[0];
            [_courseBtn setTitle:dict[@"name"] forState:UIControlStateNormal];

            [self addRefreshLoadMore];
        }
    } failure:^(NSError *error) {}];
    else
    {
        [self addRefreshLoadMore];
    }
}

-(void)getUpCourseIdOfReloadNeData:(NSNumber*)classId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/course/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":classId} success:^(id responseObject){
        
        // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        if(array.count>0)
        {
            NSDictionary*dict=array[0];
            _firstClassOfFirstCourseDict=array[0];
            [_courseBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
            [self loadNewData];
        }
    } failure:^(NSError *error) {}];
}

-(void)selBtnClicked:(UIButton*)btn
{
    XXYClassListController*classCon=[[XXYClassListController alloc]init];
    switch (btn.tag) {
        case 1:
        {
            classCon.titleName=@"班级";
            classCon.sendClassInfoDictDelegate=self;
            classCon.index=1;

        }
            break;
        case 2:
        {
            classCon.titleName=@"课程";
            classCon.publishDelegate=self;
            classCon.classOfId=_firstClassDict[@"id"];
            classCon.index=3;
        }
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:classCon animated:YES];
}
-(void)sendClassInfoDict:(NSDictionary *)dict andIndex:(NSInteger)index
{
    if(index==1)
    {
        _firstClassDict=dict;
        [_classBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
        
        [self getUpCourseIdOfReloadNeData:_firstClassDict[@"id"]];
        //[self loadNewData];
    }
}
-(void)sendPublishTypeName:(NSString *)title andIndex:(NSInteger)index andtypeId:(NSNumber *)typeId
{
    if(index==3)
    {
        [_courseBtn setTitle:title forState:UIControlStateNormal];
        _firstClassOfFirstCourseDict=@{@"name":title,@"id":typeId};
        [self loadNewData];
    }
}
@end
