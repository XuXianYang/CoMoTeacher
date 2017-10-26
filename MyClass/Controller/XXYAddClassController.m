#import "XXYAddClassController.h"
#import "XXYBackButton.h"
#import "XXYInfoOfClassForJoinController.h"
#import "BSHttpRequest.h"
@interface XXYAddClassController ()<XXYSendClassInfoDelegate>

@property(nonatomic,strong)UIButton*joinClassBtn;
@property(nonatomic,strong)NSNumber*courseId;
@property(nonatomic,copy)NSString*enroYear;
@property(nonatomic,copy)NSString*courseName;
@property(nonatomic,strong)NSNumber*classNumbers;
@end
@implementation XXYAddClassController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"添加班级";
    self.view.backgroundColor=XXYBgColor;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpSubViews];
}
-(void)setUpSubViews
{
    NSArray*nameArray=@[@"学  年:",@"班  级:",@"学  科:"];
    NSArray*placeHoder=@[@"请选择学年",@"请选择班级",@"请选择学科"];
    for(int i=0;i<3;i++)
    {
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 40+i*70, 60, 50)];
        label.textAlignment=NSTextAlignmentRight;
        label.text=nameArray[i];
        label.textColor=XXYCharactersColor;
        [self.view addSubview:label];
        
        UIButton*selBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        selBtn.frame=CGRectMake(65, 40+5+70*i, MainScreenW-75, 40);
        [selBtn setTitle:placeHoder[i] forState:UIControlStateNormal];
        [selBtn setBackgroundColor:[UIColor whiteColor]];
        [selBtn setTitleColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0] forState:UIControlStateNormal];
        selBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
        selBtn.titleLabel.font=[UIFont systemFontOfSize:17];
        [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        selBtn.tag=1+i;
        [self.view addSubview:selBtn];
    }
    
    _joinClassBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _joinClassBtn.frame=CGRectMake(20, 300, MainScreenW-40, 40);
    [_joinClassBtn addTarget:self action:@selector(joinClassBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_joinClassBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_joinClassBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    _joinClassBtn.layer.cornerRadius=5;
    [_joinClassBtn setTitle:@"加入班级" forState:UIControlStateNormal];
    [self.view addSubview:_joinClassBtn];
}
-(void)joinClassBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/join"];
    
    if(_enroYear.length==0)
    {
        [SVProgressHUD showErrorWithStatus:@"请选择学年"];
    }
    else if (_classNumbers.integerValue<=0)
    {
         [SVProgressHUD showErrorWithStatus:@"请选择班级"];
    }
    else if (_courseId.integerValue<=0)
    {
         [SVProgressHUD showErrorWithStatus:@"请选择课程"];
    }
   else
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"enrolYear":_enroYear,@"classNumber":_classNumbers,@"courseIds":_courseId} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            NSArray*successClass=objString[@"data"][@"successClasses"];
            if(successClass.count>0)
            {
                for (NSDictionary*dict in objString[@"data"][@"successClasses"])
                {
                    if(dict)
                    {
//                        NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
//                        NSArray*classListArray=[defaultss objectForKey:@"teacherClassList"];
//                        NSMutableArray*classOfNew=[NSMutableArray arrayWithArray:classListArray];
//                        
//                        [classOfNew addObject:dict];
//                        [defaultss setObject:classOfNew forKey:@"teacherClassList"];
                        
                        if([self.reloadDelegate respondsToSelector:@selector(reloadNewClassData)])
                        {
                            [self.reloadDelegate reloadNewClassData];
                        }

                        [self.navigationController popViewControllerWithAnimation];
                        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"成功加入%@-%@",dict[@"name"],_courseName]];
                    }
                    else
                    {
                        [SVProgressHUD showSuccessWithStatus:@"加入班级失败!"];
                    }
                }
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"加入班级失败!"];
            }
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"加入班级失败!"];
        }
    } failure:^(NSError *error) {
    
        [SVProgressHUD showSuccessWithStatus:@"加入班级失败!"];
    }];
}

-(void)selBtnClicked:(UIButton*)btn
{
    NSArray*array=@[@"学年",@"班级",@"学科"];
    XXYInfoOfClassForJoinController*con=[[XXYInfoOfClassForJoinController alloc]init];
    con.index=btn.tag;
    con.titleName=array[btn.tag-1];
    con.sendclassInfoDelegate=self;
    [self.navigationController pushViewController:con animated:YES];
}
-(void)sendclassInfo:(id)multipleChoiceData andIndex:(NSInteger)index
{
    NSString*btnTitle=@"";
    switch (index) {
        case 1:
        {
            if(multipleChoiceData)
            {
                NSString*dataString=multipleChoiceData;
                btnTitle=dataString;
                _enroYear=btnTitle;
            }
        }
            break;
        case 2:
            if(multipleChoiceData)
            {
                    NSString*dataString=multipleChoiceData;
                
                    btnTitle=dataString;
                
                    NSString*stringNum=[dataString substringWithRange:NSMakeRange(0, dataString.length-1)];
                    int num=[stringNum intValue];
                    NSNumber*number=[NSNumber numberWithInt:num];
                   _classNumbers=number;
            }
            break;
        case 3:
            
            if(multipleChoiceData)
            {
                    NSDictionary*dict=multipleChoiceData;
                    btnTitle=dict[@"name"];
                   _courseId=dict[@"id"];
                _courseName=btnTitle;
            }
            break;
        default:
            break;
    }
    UIButton*btn=[self.view viewWithTag:index];
    [btn setTitle:btnTitle forState:UIControlStateNormal];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
