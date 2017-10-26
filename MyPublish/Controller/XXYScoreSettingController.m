#import "XXYScoreSettingController.h"
#import "BSHttpRequest.h"
#import "XXYBackButton.h"
@interface XXYScoreSettingController ()<UITextFieldDelegate>

@property(nonatomic,strong)UIButton*comfirmBtn;
@property(nonatomic,strong)UITextField*studentScoreField;

@end

@implementation XXYScoreSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    self.navigationItem.title=self.titleName;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;

    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    [self setUpSubViews];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)setUpSubViews
{
    _comfirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _comfirmBtn.frame=CGRectMake(30,150, MainScreenW-60, 50);
    [_comfirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_comfirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_comfirmBtn addTarget:self action:@selector(commitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _comfirmBtn.titleLabel.font=[UIFont systemFontOfSize:19];
    _comfirmBtn.layer.cornerRadius=5;
    [_comfirmBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    [self.view addSubview:_comfirmBtn];
    
    _studentScoreField=[[UITextField alloc]init];
    _studentScoreField.frame=CGRectMake(30, 50, MainScreenW-60, 50);
    [_studentScoreField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _studentScoreField.backgroundColor=[UIColor whiteColor];
    _studentScoreField.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    _studentScoreField.layer.cornerRadius=5;
    _studentScoreField.delegate=self;
    _studentScoreField.text=self.studentScore;
    _studentScoreField.textAlignment=NSTextAlignmentCenter;
    _studentScoreField.placeholder=@"  请输入学生成绩";
    [self.view addSubview:_studentScoreField];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //注销第一响应者身份,隐藏键盘
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.studentScoreField)
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.studentScoreField)
    {
        if (textField.text.length > 6)
        {
            textField.text = [textField.text substringToIndex:6];
        }
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_studentScoreField resignFirstResponder];
}
-(void)commitBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSMutableDictionary*jsonParametersArr=[NSMutableDictionary dictionary];
    [jsonParametersArr setObject:self.studentScoreField.text forKey:self.studentId];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonParametersArr options:NSJSONWritingPrettyPrinted error:nil];
    NSString*str= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/quiz/score/set"];
    
//    NSLog(@"str=%@",str);
//    NSLog(@"str1=%@",self.classId);
//    NSLog(@"str2=%@",self.quizId);
//    NSLog(@"sid=%@",userSidString);
    
    self.studentScoreField.text= [self.studentScoreField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.studentScoreField.text.length<=0)
    {
        [SVProgressHUD showErrorWithStatus:@"成绩不能为空!"];
    }
    
  else if(self.classId&&self.quizId&&self.studentScoreField.text&&self.studentId)
        
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":self.classId,@"quizId":self.quizId,@"studentScores":str}success:^(id responseObject){
            
          //  NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if([objString[@"message"] isEqualToString:@"success"])
            {
                if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
                {
                    [self.reloadDelegate reloadTableView];
                }
                [self.navigationController popViewControllerAnimated:YES];
                [SVProgressHUD showSuccessWithStatus:@"设置成绩成功!"];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"设置成绩失败!"];
            }
        } failure:^(NSError *error) {
            
            [SVProgressHUD showSuccessWithStatus:@"设置成绩失败!"];
            
        }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
