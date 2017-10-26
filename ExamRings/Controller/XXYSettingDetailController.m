#import "XXYBackButton.h"
#import "XXYSettingDetailController.h"
#import"BSHttpRequest.h"
#import"XXYWebViewController.h"
#import"AppDelegate.h"
@interface XXYSettingDetailController ()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField*oldPasswordField;
@property(nonatomic,strong)UITextField*newsPasswordField;
@property(nonatomic,strong)UIButton*confirmBtn;
@property(nonatomic,strong)UITextField*realNameField;
@property(nonatomic,strong)UIButton*saveBtn;
@property(nonatomic,strong)UITextField*confirmpasswordTextField;

@end
@implementation XXYSettingDetailController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.titleName;
    self.view.backgroundColor=XXYBgColor;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    switch (self.index)
    {
        case 1:
            [self changePassword];
            [self setUpBtn];
            _confirmBtn.frame=CGRectMake(10, 45*5, MainScreenW-20, 45);
            break;
        case 2:
            [self personInfo];
            [self setUpBtn];
            
            _confirmBtn.frame=CGRectMake(10, 105, MainScreenW-20, 45);
            break;
        case 3:
            [self aboutUs];
            break;
        default:
            break;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [_oldPasswordField becomeFirstResponder];
    [_realNameField becomeFirstResponder];
}
-(void)changePassword
{
    _oldPasswordField=[[UITextField alloc]initWithFrame:CGRectMake(10,45, MainScreenW-20, 45)];
    _oldPasswordField.delegate=self;
    _oldPasswordField.placeholder=@"请输入旧的登录密码";
    _oldPasswordField.backgroundColor=[UIColor whiteColor];
    _oldPasswordField.secureTextEntry=YES;
    UIView*oldView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _oldPasswordField.leftView=oldView;
    _oldPasswordField.leftViewMode=UITextFieldViewModeAlways;
    _oldPasswordField.clearButtonMode =UITextFieldViewModeAlways;
    [_oldPasswordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_oldPasswordField];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, MainScreenW-20, 1)];
    lineView.backgroundColor=XXYBgColor;
    [_oldPasswordField addSubview:lineView];

    
    _newsPasswordField=[[UITextField alloc]initWithFrame:CGRectMake(10,90, MainScreenW-20, 45)];
    _newsPasswordField.delegate=self;
    UIView*newView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _newsPasswordField.leftView=newView;
    _newsPasswordField.leftViewMode=UITextFieldViewModeAlways;
    _newsPasswordField.secureTextEntry=YES;
    _newsPasswordField.placeholder=@"请输入新的登录密码(最多16位)";
    _newsPasswordField.clearButtonMode =UITextFieldViewModeAlways;
    _newsPasswordField.backgroundColor=[UIColor whiteColor];
    [_newsPasswordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_newsPasswordField];
    
    UIView*newlineView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, MainScreenW-20, 1)];
    newlineView.backgroundColor=XXYBgColor;
    [_newsPasswordField addSubview:newlineView];
    
    _confirmpasswordTextField=[[UITextField alloc]initWithFrame:CGRectMake(10,135, MainScreenW-20, 45)];
    _confirmpasswordTextField.delegate=self;
    UIView*conView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _confirmpasswordTextField.leftView=conView;
    _confirmpasswordTextField.leftViewMode=UITextFieldViewModeAlways;
    _confirmpasswordTextField.secureTextEntry=YES;
    _confirmpasswordTextField.placeholder=@"请再次确认新的登录密码";
    _confirmpasswordTextField.clearButtonMode =UITextFieldViewModeAlways;
    _confirmpasswordTextField.backgroundColor=[UIColor whiteColor];
    [_confirmpasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:_confirmpasswordTextField];
}
-(void)setUpBtn
{
    _confirmBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 190, MainScreenW-20, 45)];
    _confirmBtn.layer.cornerRadius=5;
    [_confirmBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmBtn];
    switch (self.index)
    {
        case 1:
            [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
            break;
        case 2:
            [_confirmBtn setTitle:@"保存" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    _confirmBtn.tag=self.index;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //注销第一响应者身份,隐藏键盘
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_newsPasswordField resignFirstResponder];
    [_oldPasswordField resignFirstResponder];
    [_realNameField resignFirstResponder];
    [_confirmpasswordTextField resignFirstResponder];
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.newsPasswordField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
        
    }
    if (textField == self.oldPasswordField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
    }
    if (textField == self.confirmpasswordTextField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
        
    }

    if (textField == self.realNameField)
    {
        if (textField.text.length >8)
        {
            textField.text = [textField.text substringToIndex:8];
        }
    }
}
-(void)confirmBtnCliked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*urlString;
    NSString*successString;
    NSString*errorString;
    NSDictionary*parameters;
    if(btn.tag==1)
    {
        urlString=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/register/modifyPassword"];
        successString=@"修改密码成功";
        errorString=@"修改密码失败";
        parameters=@{@"sid":userSidString,@"oldPassword":_oldPasswordField.text,@"newPassword":_newsPasswordField.text};
        
        if(_oldPasswordField.text.length<6||_newsPasswordField.text.length<6||_confirmpasswordTextField.text.length<6)
        {
            [self setUpAlertController:@"密码最少为6位!"];
        }
        else if ([XXYMyTools isEmpty:_oldPasswordField.text]||[XXYMyTools isEmpty:_newsPasswordField.text]||[XXYMyTools isEmpty:_confirmpasswordTextField.text])
        {
            [self setUpAlertController:@"密码不能含有空格等字符"];
        }
        else if (![_newsPasswordField.text isEqualToString:_confirmpasswordTextField.text])
        {
            [self setUpAlertController:@"密码不一致"];
        }
        else
        {
            [self postData:urlString AndPar:parameters andErr:errorString andSuccess:successString];
        }
    }
    if(btn.tag==2)
    {
        urlString=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info/update"];
        successString=@"保存成功";
        errorString=@"保存失败";
        parameters=@{@"sid":userSidString,@"realName":_realNameField.text};
        if(_realNameField.text.length==0||[XXYMyTools isEmpty:_realNameField.text])
        {
            [self setUpAlertController:@"姓名不能为空或含有空格等字符"];
        }
        else
        {
            [self postData:urlString AndPar:parameters andErr:errorString andSuccess:successString];
        }
    }
}
-(void)postData:(NSString*)url AndPar:(NSDictionary*)dict andErr:(NSString*)errorStr andSuccess:(NSString*)suc
{
    [BSHttpRequest POST:url parameters:dict success:^(id responseObject){
        // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString*codeStr=objString[@"code"];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showSuccessWithStatus:suc];
        }
        else if (codeStr.integerValue==1007)
        {
            [SVProgressHUD showSuccessWithStatus:@"旧密码不正确"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:objString[@"message"]];
        }
    } failure:^(NSError *error) {
        // NSLog(@"e-%@",error.localizedDescription);
        [SVProgressHUD showSuccessWithStatus:errorStr];
        
    }];

}
-(void)personInfo
{
    _realNameField=[[UITextField alloc]initWithFrame:CGRectMake(10,40, MainScreenW-20, 45)];
    _realNameField.layer.cornerRadius=5;
    _realNameField.textAlignment=NSTextAlignmentLeft;
    _realNameField.delegate=self;
    _realNameField.placeholder=@"请输入新的名字";
    UIView*newView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _realNameField.leftView=newView;
    _realNameField.leftViewMode=UITextFieldViewModeAlways;
    _realNameField.backgroundColor=[UIColor whiteColor];
    _realNameField.clearButtonMode =UITextFieldViewModeAlways;
    [_realNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_realNameField];
}
-(void)aboutUs
{
    UIDevice*device= [UIDevice currentDevice];
    
    CGFloat picHeight=0.0;
    if([device.model isEqualToString:@"iPad"])
    {
        picHeight=(MainScreenW-305)/2+120;
    }
    else
    {
        picHeight=MainScreenW-240+35;
    }

    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-100)/2, (picHeight+64-100)/2, 100, 100)];
    imageView.layer.masksToBounds=YES;
    imageView.layer.cornerRadius=10;
    imageView.image=[UIImage imageNamed:@"login_icon"];
    [self.view addSubview:imageView];
    
    
    UILabel*nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, (picHeight+64-100)/2+110, MainScreenW-40, 30)];
    nameLabel.text=@"教师端V1.0.1";
    nameLabel.textColor=XXYCharactersColor;
    nameLabel.font=[UIFont systemFontOfSize:17];
    //nameLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:20];
    nameLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(0, picHeight+70 , MainScreenW, 120)];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    for (int i=0;i<2;i++)
    {
        UIView*label=[[UIView alloc]initWithFrame:CGRectMake(0,40*(i+1), MainScreenW, 1)];
        label.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        [bgView addSubview:label];
        
    }
    UIView*LastBgView=[[UIView alloc]initWithFrame:CGRectMake(0, picHeight+210, MainScreenW, 80)];
    LastBgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:LastBgView];
    
    UIView*seplabel=[[UIView alloc]initWithFrame:CGRectMake(0,40, MainScreenW, 1)];
    seplabel.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    [LastBgView addSubview:seplabel];
    
    NSArray*secondTitleArray=@[@"检查更新",@"给我评分"];
    
    for(int i=0;i<2;i++)
    {
        UIButton*lastbtn=[UIButton buttonWithType:UIButtonTypeSystem];
        [lastbtn setBackgroundColor:[UIColor clearColor]];
        lastbtn.frame=CGRectMake(0, 40*i, MainScreenW, 40);
        lastbtn.tag=100+i;
        [lastbtn addTarget:self action:@selector(lastBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [LastBgView addSubview:lastbtn];
        
        UILabel*secondTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 5, 100, 30)];
        secondTitleLabel.textColor=XXYCharactersColor;
        secondTitleLabel.text=secondTitleArray[i];
        secondTitleLabel.font=[UIFont systemFontOfSize:16];
        [lastbtn addSubview:secondTitleLabel];
        
        UIImageView*secImageView=[[UIImageView alloc]initWithFrame:CGRectMake(MainScreenW-40, 10, 20, 20)];
        secImageView.image=[UIImage imageNamed:@"icon_img"];
        [lastbtn addSubview:secImageView];
    }
    NSArray*firstTitleArray=@[@"官方网站:",@"客服电话:",@"微信号:"];
    NSArray*firstBtnArray=@[@"http://comoclass.com",@"021-52992729",@"comoclass"];
    for (int i=0;i<3;i++)
    {
        UILabel*firstTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 5+40*i, 80, 30)];
        firstTitleLabel.text=firstTitleArray[i];
        firstTitleLabel.textColor=XXYCharactersColor;
        firstTitleLabel.font=[UIFont systemFontOfSize:16];
        [bgView addSubview:firstTitleLabel];
        
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
        CGSize size=[firstBtnArray[i] sizeWithAttributes:attrs];
        
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame=CGRectMake(110, 5+40*i, size.width, 30);
        [btn setTitle:firstBtnArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.tag=i+1;
        btn.titleLabel.textAlignment=NSTextAlignmentCenter;
        btn.titleLabel.font=[UIFont systemFontOfSize:14];;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        
        UIImageView*firstImageView=[[UIImageView alloc]initWithFrame:CGRectMake(MainScreenW-40, 10+40*i, 20, 20)];
        firstImageView.image=[UIImage imageNamed:@"icon_img"];
        [bgView addSubview:firstImageView];
        
    }
    UILabel*timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,MainScreenH-64-30,MainScreenW, 20)];
    timeLabel.textAlignment=NSTextAlignmentCenter;
    timeLabel.textColor=[UIColor lightGrayColor];
    timeLabel.font=[UIFont systemFontOfSize:12];
    timeLabel.text=@"服务时间: 09:00~18:00";
    [self.view addSubview:timeLabel];
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alert = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
        
    }];
    alert = nil;
}

-(void)lastBtnCliked:(UIButton*)btn
{
    switch (btn.tag)
    {
        case 100:
        {
            [SVProgressHUD showSuccessWithStatus:@"当前版本已经是最新版本了"];
            
        }
            break;
        case 101:
        {
            //1156784420
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1156784420&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }
            break;
        default:
            break;
    }
}
-(void)btnClicked:(UIButton*)btn
{
    switch (btn.tag)
    {
        case 1:
        {
            XXYWebViewController*webCon=[[XXYWebViewController alloc]init];
            [self.navigationController pushViewControllerWithAnimation:webCon];
        }
            break;
        case 2:
        {
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",btn.currentTitle];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            [self.view addSubview:callWebview];
        }
            break;
        case 3:
        {
            [SVProgressHUD showSuccessWithStatus:@"请搜索酷么课堂,关注最新动态"];
        }
            break;
        default:
            break;
    }
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}@end
