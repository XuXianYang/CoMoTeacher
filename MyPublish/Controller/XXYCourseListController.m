#import "BSHttpRequest.h"
#import "XXYCourseListController.h"
#import "XXYBackButton.h"
@interface XXYCourseListController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,retain)NSMutableArray*dataList;

@end

@implementation XXYCourseListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"修改课程";
    self.view.backgroundColor=XXYBgColor;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.bounces=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenH-64) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/all"];
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray*array=objString[@"data"];
            for (NSDictionary*dict in array)
            {
                [self.dataList addObject:dict];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
        }];
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
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text=self.dataList[indexPath.row][@"name"];
    cell.textLabel.textColor=XXYCharactersColor;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self modifyCourse:[NSNumber numberWithInteger:indexPath.row+1]];
}
-(void)modifyCourse:(NSNumber*)modifyCourseId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/course/schedule"];

    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":self.classId} success:^(id responseObject) {

        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray*dataArray=obj[@"data"];
        for(int i=0;i<dataArray.count;i++)
        {
            NSDictionary*dict=dataArray[i];
            if([dict[@"dayOfWeek"] isEqual:self.dayOfWeek]&&[dict[@"lessonOfDay"] isEqual:self.lessonOfDay])
            {
                [dataArray removeObjectAtIndex:i];
            }
        }
        NSString*string=@"123";
        
        for(int i=0;i<dataArray.count;i++)
        {
           NSDictionary*dict=dataArray[i];
            NSString*st=[NSString stringWithFormat:@"{\"courseId\":%@,\"dayOfWeek\":%@,\"lessonOfDay\":%@}",dict[@"course"][@"id"],dict[@"dayOfWeek"],dict[@"lessonOfDay"]];
            string=[NSString stringWithFormat:@"%@,%@",string,st];
        }
        NSString*str2=[NSString stringWithFormat:@"{\"courseId\":%@,\"dayOfWeek\":%@,\"lessonOfDay\":%@}",modifyCourseId,self.dayOfWeek,self.lessonOfDay];
        
        
        
        string=[NSString stringWithFormat:@"%@,%@",string,str2];
        
        string=[string substringWithRange:NSMakeRange(4, string.length-4)];
        string=[NSString stringWithFormat:@"[%@]",string];
        
//        NSLog(@"123456=%@",string);
        
        [self setUpModifyCourse:string];
        
    } failure:^(NSError *error) {}];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setUpModifyCourse:(NSString*)parameterString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/course/schedule/set"];

    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":self.classId,@"courseSchedules":parameterString} success:^(id responseObject) {
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString*codeStr=obj[@"code"];
        
        if([obj[@"message"] isEqualToString:@"success"])
        {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
            {
                [self.reloadDelegate reloadTableView];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
       else if(codeStr.integerValue==4001)
        {
            [SVProgressHUD showSuccessWithStatus:@"您可能没有权限,修改失败"];
        }

        else
        {
            [SVProgressHUD showSuccessWithStatus:@"修改失败"];
           
        }
           } failure:^(NSError *error) {
               
               [SVProgressHUD showSuccessWithStatus:@"修改失败"];
               //NSLog(@"%@",error.localizedDescription);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
