#import "XXYTimeTableView.h"
#import "XXYTimeTableModel.h"
#import "XXYTimeTableViewCell.h"
#import "MJRefresh.h"

#import "BSHttpRequest.h"
@interface XXYTimeTableView ()<UITableViewDataSource, UITableViewDelegate>


@end

@implementation XXYTimeTableView
+ (XXYTimeTableView *)contentTableView
{
    XXYTimeTableView *contentTV = [[XXYTimeTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    contentTV.backgroundColor = [UIColor clearColor];
    contentTV.dataSource = contentTV;
    contentTV.separatorStyle=UITableViewCellSeparatorStyleNone;
    contentTV.delegate = contentTV;
    
    return contentTV;
}
//添加刷新加载更多
-(void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    [header beginRefreshing];
    
    self.mj_header = header;
}

-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/course/schedule"];

    if(_firstClassDict)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"classId":_firstClassDict[@"id"]} success:^(id responseObject) {
        
        [self.mj_header endRefreshing];
        
        //先清空数据源
        [self.courseDataList removeAllObjects];

        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArray=obj[@"data"];
        [BSHttpRequest archiverObject:dataArray ByKey:@"timeTableList" WithPath:@"timeTableList.plist"];
        [self turnArrToModel:dataArray];
         [self reloadData];
    } failure:^(NSError *error) {
        [self.courseDataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"timeTableList" WithPath:@"timeTableList.plist"];
        [self turnArrToModel:array];
        [self reloadData];
        [self.mj_header endRefreshing];

    }];
    else
    {
        [self.mj_header endRefreshing];
    }
}
-(void)turnArrToModel:(NSArray*)array
{
    NSArray*courseNum=@[@"第一节",@"第二节",@"第三节",@"第四节",@"第五节",@"第六节",@"第七节",@"第八节"];
    
    for(int i=1;i<6;i++)
    {
        for(int j=1;j<9;j++)
        {
            XXYTimeTableModel*model=[[XXYTimeTableModel alloc]init];
            
            model.courseNum=courseNum[j-1];
            for (NSDictionary*dict in array)
            {
                
                if([dict[@"dayOfWeek"] isEqualToNumber:[NSNumber numberWithInt:i]]&&[dict[@"lessonOfDay"] isEqualToNumber:[NSNumber numberWithInt:j]])
                {
                    
                    model.courseName=dict[@"course"][@"name"];
                    break ;
                }
                else
                {
                    model.courseName=@"";
                }
            }
            [self.courseDataList addObject:model];
        }
    }
}
-(NSMutableArray*)courseDataList
{
    if(!_courseDataList)
    {
        _courseDataList=[NSMutableArray array];
    }
    return _courseDataList;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.courseDataList.count/5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self registerNib:[UINib nibWithNibName:@"XXYTimeTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"timeTableCellId"];
    XXYTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeTableCellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.index=indexPath.section;

    switch (self.index)
    {
        case 1:
            cell.dataModel =self.courseDataList[indexPath.section];
            break;
        case 2:
            cell.dataModel =self.courseDataList[indexPath.section+8];
            break;
        case 3:
            cell.dataModel =self.courseDataList[indexPath.section+16];
            break;
        case 4:
            cell.dataModel =self.courseDataList[indexPath.section+24];
            break;
        case 5:
            cell.dataModel =self.courseDataList[indexPath.section+32];
            break;
  
        default:
            break;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.turnNextControllerDelegate respondsToSelector:@selector(turnNextController:And:)])
    {
        [self.turnNextControllerDelegate turnNextController:[NSNumber numberWithInteger:indexPath.section+1] And:[NSNumber numberWithInteger:self.index]];
    }
    
    
}

@end
