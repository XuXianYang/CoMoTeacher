#import "XXYInfoOfClassForJoinController.h"
#import "XXYBackButton.h"
#import"BSHttpRequest.h"
@interface XXYInfoOfClassForJoinController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,retain)NSArray*dataList;

@property(nonatomic,retain)NSMutableArray*yearList;
@property(nonatomic,retain)NSMutableArray*classList;
@property(nonatomic,retain)NSMutableArray*courseList;

//@property(nonatomic,retain)NSMutableArray*multipleChoiceDataList;

@end

@implementation XXYInfoOfClassForJoinController

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
    self.tableView.showsVerticalScrollIndicator=NO;
    
//    //设置编辑按钮
//    if(self.index!=1)
//    {
//        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(commitItemClicked:)];
//        [super setEditing:YES animated:YES];
//        [_tableView setEditing:YES animated:YES];
//    }
}
//-(void)commitItemClicked:(UIBarButtonItem*)item
//{
//    if([self.sendclassInfoDelegate respondsToSelector:@selector(sendclassInfo:andIndex:)])
//    {
//       [self.sendclassInfoDelegate sendclassInfo:self.multipleChoiceDataList andIndex:self.index ];
//    }
//    [self.navigationController popViewControllerAnimated:YES];
//}
////编辑风格
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
//}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenH-64) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray*)yearList
{
    if(!_yearList)
    {
        _yearList=[NSMutableArray array];
        for(int i=0;i<20;i++)
        {
            NSString*string=[NSString stringWithFormat:@"%i",i+2012];
            [_yearList addObject:string];
        }
    }
    return _yearList;
}
//-(NSMutableArray*)multipleChoiceDataList
//{
//    if(!_multipleChoiceDataList)
//    {
//        _multipleChoiceDataList=[NSMutableArray array];
//    }
//    return _multipleChoiceDataList;
//}

-(NSMutableArray*)classList
{
    if(!_classList)
    {
        _classList=[NSMutableArray array];
        for(int i=0;i<50;i++)
        {
            NSString*string=[NSString stringWithFormat:@"%i班",i+1];
            [_classList addObject:string];
        }
    }
    return _classList;
}
-(NSMutableArray*)courseList
{
    if(!_courseList)
    {
        _courseList=[NSMutableArray array];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
        
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/all"];
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray*array=objString[@"data"];
            for (NSDictionary*dict in array)
            {
                [self.courseList addObject:dict];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
        }];

    }
    return _courseList;
}
-(NSArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSArray array];
        if(self.index==1)
            _dataList=self.yearList;
        if(self.index==2)
            _dataList=self.classList;
        if(self.index==3)
            _dataList=self.courseList;
    }
    return _dataList;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:@"cellId"];
    }
    cell.textLabel.textColor=XXYCharactersColor;
    if(self.index==3)
    {
        NSDictionary*dict=self.dataList[indexPath.row];
        cell.textLabel.text=dict[@"name"];
    }
    else
    {
        cell.textLabel.text=self.dataList[indexPath.row];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.sendclassInfoDelegate respondsToSelector:@selector(sendclassInfo:andIndex:)])
    {
            [self.sendclassInfoDelegate sendclassInfo:self.dataList[indexPath.row] andIndex:self.index ];
    }
    [self.navigationController popViewControllerAnimated:YES];

//    if(_tableView.editing)
//    {
//        [self.multipleChoiceDataList addObject:self.dataList[indexPath.row]];
//    }
//    else
//    {
//        [self.multipleChoiceDataList addObject:self.dataList[indexPath.row]];
//        
//    }
}
////取消状态从数组中删除数组
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.multipleChoiceDataList removeObject:self.dataList[indexPath.row]];
//    
//}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
