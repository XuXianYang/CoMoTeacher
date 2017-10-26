#import "XXYJoinSchoolController.h"
#import "BSHttpRequest.h"
#import "AppDelegate.h"
#import "LMComBoxView.h"
@interface XXYJoinSchoolController ()<UITextFieldDelegate,LMComBoxViewDelegate>

@property(nonatomic,strong)UITextField*schoolCodeTextField;
@property(nonatomic,strong)UIButton*joinSchoolBtn;
@property(nonatomic,strong)UIImageView*bgImageView;
@property (nonatomic, strong) LMComBoxView *comBox;
@property(nonatomic,retain)NSArray*dataArray;
@property(nonatomic,strong)NSNumber*schoolId;

@end

@implementation XXYJoinSchoolController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"加入学校";
    self.view.backgroundColor=[UIColor whiteColor];
    
    _bgImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    _bgImageView.image=[[UIImage imageNamed:@"bg_join_class"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _bgImageView.userInteractionEnabled=YES;
    [self.view addSubview:_bgImageView];
    
    [self setUpSubviews];
    
    [self setUpNavigationControllerBackButton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _dataArray=[defaults objectForKey:@"schoolInfoList"];
    
    if(_dataArray.count>0)
    {
        NSDictionary*schoolInfoDict=_dataArray[0];
        _schoolId=schoolInfoDict[@"id"];
        //NSLog(@"schoolId=%@",_schoolId);
        [self setUpBgScrollView:[NSMutableArray arrayWithArray:_dataArray]];
    }
    else
    {
        UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取学校列表失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertCon addAction:action2];
        [self presentViewController:alertCon animated:YES completion:nil];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //设置导航栏为透明色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];

}
-(void)setUpNavigationControllerBackButton
{
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(0, 0, 30, 30);
   
    UIBarButtonItem*btnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItems=@[btnItem];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUpBgScrollView:(NSMutableArray*)array
{
    _comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(20, MainScreenH/2-160, MainScreenW-40, 40)];
    _comBox.layer.cornerRadius=5;
    _comBox.backgroundColor = [UIColor whiteColor];
    _comBox.arrowImgName = @"down_dark0.png";
    NSMutableArray*dataArr=[NSMutableArray array];
    for (NSDictionary*dict in array)
    {
        NSString*titleName=dict[@"name"];
        [dataArr addObject:titleName];
    }
        _comBox.titlesList = dataArr;
    _comBox.delegate = self;
    _comBox.supView = self.view;
    [_comBox defaultSettings];
    _comBox.tag = 100;
    [self.view addSubview:_comBox];
}
#pragma mark -LMComBoxViewDelegate
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox
{
   // NSLog(@"title=%@",_combox.titlesList[index]);
    NSDictionary*dict=_dataArray[index];
    _schoolId=dict[@"id"];
    //NSLog(@"id=%@",dict[@"id"]);
}
-(void)setUpSubviews
{
    _schoolCodeTextField=[[UITextField alloc]initWithFrame:CGRectMake(20, MainScreenH/2-100, MainScreenW-40, 40)];
    _schoolCodeTextField.layer.cornerRadius=5;
    _schoolCodeTextField.delegate=self;
    _schoolCodeTextField.backgroundColor=[UIColor whiteColor];
    _schoolCodeTextField.placeholder=@"请填写学校码";
    UIView*newView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)];
    _schoolCodeTextField.leftView=newView;
    _schoolCodeTextField.keyboardType=UIKeyboardTypeASCIICapable;
    _schoolCodeTextField.leftViewMode=UITextFieldViewModeAlways;
    _schoolCodeTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_schoolCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_bgImageView addSubview:_schoolCodeTextField];
    
    _joinSchoolBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _joinSchoolBtn.frame=CGRectMake(20,MainScreenH/2-40, MainScreenW-40, 40);
    _joinSchoolBtn.layer.cornerRadius=5;
    [_joinSchoolBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    _joinSchoolBtn.titleLabel.font=[UIFont systemFontOfSize:19];
    [_joinSchoolBtn setTitle:@"加入学校" forState:UIControlStateNormal];
    [_joinSchoolBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_joinSchoolBtn addTarget:self action:@selector(joinSchoolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgImageView addSubview:_joinSchoolBtn];
}
-(void)joinSchoolBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/school/join"];
    if([XXYMyTools isEmpty:_schoolCodeTextField.text]||[XXYMyTools isChinese:_schoolCodeTextField.text]||_schoolCodeTextField.text.length==0)
    {
        [self setUpAlertController:@"学校编码不能包含中文,空格等字符"];
    }
    else
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"code":_schoolCodeTextField.text,@"id":_schoolId} success:^(id responseObject){
        
        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSNumber*num=objString[@"code"];
        
        if([objString[@"message"] isEqualToString:@"success"]&&[num integerValue]==0)
        {
            //加入学校成功之后,删除学校列表
            [defaults removeObjectForKey:@"schoolInfoList"];
            
            UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"加入学校成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertCon addAction:action1];

            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"login"];
            }];
            [alertCon addAction:action2];
            [self presentViewController:alertCon animated:YES completion:nil];

        }
        else
        {
            NSString*failString=objString[@"message"];
            [self setUpAlertController:failString];
        }
        
        } failure:^(NSError *error){
        [self setUpAlertController:@"加入学校失败"];
        }];

}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
         [self presentViewController:alertCon animated:YES completion:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //注销第一响应者身份,隐藏键盘
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_schoolCodeTextField resignFirstResponder];
    if(_comBox.isOpen)
    {
        [_comBox tapAction];
    }

}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.schoolCodeTextField)
    {
        if (textField.text.length > 12)
        {
            textField.text = [textField.text substringToIndex:12];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
