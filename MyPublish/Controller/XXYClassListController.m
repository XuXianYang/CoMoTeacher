#import "XXYClassListController.h"
#import "XXYBackButton.h"
#import "XXYPublishCoursewareController.h"
#import "BSHttpRequest.h"

@interface XXYClassListController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,retain)NSArray*dataList;
@property(nonatomic,retain)NSMutableArray*classList;
@property(nonatomic,retain)NSArray*courseTypeList;
@property(nonatomic,retain)NSMutableArray*courseList;
@property(nonatomic,retain)NSArray*courseTypeIdList;
@property(nonatomic,retain)NSMutableArray*courseIdList;
@property(nonatomic,retain)NSMutableArray*classIdList;
@property(nonatomic,retain)NSMutableArray*classInfoDictList;

@end

@implementation XXYClassListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=self.titleName;

    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.bounces=NO;
    
}
-(NSMutableArray*)classIdList
{
    if(!_classIdList)
    {
        _classIdList=[NSMutableArray array];
    }
    return _classIdList;
}
-(NSMutableArray*)courseIdList
{
    if(!_courseIdList)
    {
        _courseIdList=[NSMutableArray array];
    }
    return _courseIdList;
}
-(NSMutableArray*)classInfoDictList
{
    if(!_classInfoDictList)
    {
        _classInfoDictList=[NSMutableArray array];
    }
    return _classInfoDictList;
}
-(NSMutableArray*)classList
{
    if(!_classList)
    {
        _classList=[NSMutableArray array];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
        NSArray*classListArray=[defaults objectForKey:@"teacherClassList"];
        
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/list"];

        if(classListArray.count<=0)
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray*array=objString[@"data"];
            
            if(array.count<=0)
            {
                self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            }
            for (NSDictionary*dict in array)
            {
                NSString*string=dict[@"name"];
                
                NSNumber*num=dict[@"id"];
                [self.classList addObject:string];
                [self.classIdList addObject:num];
                
                [self.classInfoDictList addObject:dict];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
        }];
        else
        {
            for (NSDictionary*dict in classListArray)
            {
                NSString*string=dict[@"name"];
                NSNumber*num=dict[@"id"];
                [self.classList addObject:string];
                [self.classIdList addObject:num];
                [self.classInfoDictList addObject:dict];
            }
            [self.tableView reloadData];
        }
    }
    return _classList;
}
-(NSArray*)courseTypeList
{
    if(!_courseTypeList)
    {
        _courseTypeList=@[@"预习向导",@"课堂笔记",@"课件"];
    }
    return _courseTypeList;
}
-(NSArray*)courseTypeIdList
{
    if(!_courseTypeIdList)
    {
        _courseTypeIdList=@[@1,@2,@3];
    }
    return _courseTypeIdList;
}

-(NSMutableArray*)courseList
{
    if(!_courseList)
    {
        _courseList=[NSMutableArray array];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/course/list"];
        if(self.classOfId)
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":self.classOfId} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@",objString);
            NSArray*array=objString[@"data"];
            if(array.count<=0)
            {
                self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            }
            for (NSDictionary*dict in array)
            {
                NSString*string=dict[@"name"];
                [self.courseList addObject:string];
                NSNumber*str=dict[@"id"];
                [self.courseIdList addObject:str];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
        }];
        else
        {
            self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        }
    }
    return _courseList;
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, [XXYMyTools normalTableheight]) style:UITableViewStylePlain];
        
    }
    return _tableView;
}
-(NSArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSArray array];
        if(self.index==1)
            _dataList=self.classList;
        if(self.index==2)
            _dataList=self.courseTypeList;
        if(self.index==3)
            _dataList=self.courseList;
    }
    return _dataList;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%@",self.dataList);
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
    }
    cell.textLabel.text=self.dataList[indexPath.row];
    cell.textLabel.textColor=XXYCharactersColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber*num=[[NSNumber alloc]init];
    if(self.index==1)
        num=self.classIdList[indexPath.row];
    if(self.index==2)
        num=self.courseTypeIdList[indexPath.row];
    if(self.index==3)
        num=self.courseIdList[indexPath.row];
    if([self.publishDelegate respondsToSelector:@selector(sendPublishTypeName:andIndex:andtypeId:)])
    {
        [self.publishDelegate sendPublishTypeName:self.dataList[indexPath.row] andIndex:self.index andtypeId:num];
    }
    if([self.sendClassInfoDictDelegate respondsToSelector:@selector(sendClassInfoDict: andIndex:)])
    {
        [self.sendClassInfoDictDelegate sendClassInfoDict:self.classInfoDictList[indexPath.row] andIndex:self.index];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
