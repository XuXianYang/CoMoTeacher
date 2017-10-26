#import "XXYInfoSettingController.h"
#import"XXYBackButton.h"
#import "XXYSettingDetailController.h"
#import "AppDelegate.h"
#import "BSHttpRequest.h"
#import<RongIMKit/RongIMKit.h>
#import"XXYProfileSettingCell.h"

@interface XXYInfoSettingController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain)NSArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIButton*cancelBtn;
@end

@implementation XXYInfoSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"设置";
    self.view.backgroundColor=XXYBgColor;
   
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.estimatedSectionHeaderHeight=10;
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.bounces=NO;
    self.tableView.scrollEnabled=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=XXYBgColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYProfileSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];

    [self setUpCancelBtn];
}
-(void)setUpCancelBtn
{
    _cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame=CGRectMake(10,230,MainScreenW-20,50);
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    _cancelBtn.layer.cornerRadius=5;
    [_cancelBtn setTitle:@"退出" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(clickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];
}
-(void)clickCancelBtn:(UIButton*)btn
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"退出当前账号" message:@"退出账号可能会使用户缓存数据全部清空,确定退出?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [action1 setValue:[UIColor colorWithRed:10.0/255 green:188.0/255 blue:180.0/255 alpha:1] forKey:@"titleTextColor"];
    [alertCon addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"loginOut"];
        
           }];
    [action2 setValue:[UIColor colorWithRed:10.0/255 green:188.0/255 blue:180.0/255 alpha:1] forKey:@"titleTextColor"];
    [alertCon addAction:action2];
    [self presentViewController:alertCon animated:YES completion:nil];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10,0,MainScreenW-20, 180) style:UITableViewStylePlain];
        _tableView.backgroundColor=[UIColor clearColor];
    }
    return _tableView;
}
-(NSArray*)dataList
{
    if(!_dataList)
    {
        _dataList=@[@0,@1,@2];
        
    }
    return _dataList;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYProfileSettingCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.cornerRadius=5;
    NSNumber*num=self.dataList[indexPath.section];
    cell.index=[num integerValue];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYSettingDetailController*detailCon=[[XXYSettingDetailController alloc]init];
    switch (indexPath.section)
    {
        case 0:
            detailCon.titleName=@"修改密码";
            break;
        case 1:
            detailCon.titleName=@"个人资料";
            break;
        case 2:
            detailCon.titleName=@"关于我们";
            break;
            
        default:
            break;
    }
    detailCon.index=indexPath.section+1;
    [self.navigationController pushViewControllerWithAnimation:detailCon];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
