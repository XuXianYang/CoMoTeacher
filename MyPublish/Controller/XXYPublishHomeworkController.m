#import "XXYPublishHomeworkController.h"
#import "XXYBackButton.h"
#import"XXYClassListController.h"
#import "BSHttpRequest.h"

#define btnHight (MainScreenH-64-40*7)/15

@interface XXYPublishHomeworkController ()<UITextFieldDelegate,UITextViewDelegate,XXYPublishContentTypeListDelegate>
{
//    UIAlertController *_alertCon;
    UIDatePicker *_datepicker;
}
@property(nonatomic,strong)UIButton*classBtn;
@property(nonatomic,strong)UIButton*courseBtn;
@property(nonatomic,strong)UIButton*timeBtn;
@property(nonatomic,strong)UITextView*contentTextView;
@property(nonatomic,strong)UITextField*titleTextField;
@property(nonatomic,strong)UIButton*publishBtn;
@property(nonatomic,strong)UILabel*placeHoderLabel;
@property(nonatomic,assign)long courseId;
@property(nonatomic,assign)long classId;

@property(nonatomic,strong)UIView* bgView;


@end

@implementation XXYPublishHomeworkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.publishHomeworkTitle;
    
    self.view.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;

    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    [self setUpTitleLabel];
    [self setUpBtns];
    
    if(self.homeworkIndex==1)
    {
        [self useClassIdGetClassName:self.homeworkModel.classId];
        [self useCourseIdGetCourseName:self.homeworkModel.courseId];
    
        _titleTextField.text=self.homeworkModel.name;
        _contentTextView.text=self.homeworkModel.myDescription;
        _placeHoderLabel.text=nil;
        _classId=self.homeworkModel.classId;
        _courseId=self.homeworkModel.courseId;
        [_publishBtn setTitle:@"修改作业" forState:UIControlStateNormal];
        
        [_classBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_timeBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_courseBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        
        [_timeBtn setTitle:[self turnDateStringToMyString:self.homeworkModel.studyDate] forState:UIControlStateNormal];
    }
}
-(NSString*)turnDateStringToMyString:(NSString*)dateString
{
    NSArray*array=[dateString componentsSeparatedByString:@" "];
    NSString*dayString=[array[1] substringWithRange:NSMakeRange(0,((NSString*)array[1]).length-1)];
    NSString*monthString;
    NSArray*monArray=@[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
    NSArray*monNumArray=@[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    
    for (int i=0;i<monArray.count;i++) {
        if([array[0] isEqualToString:monArray[i]])
        {
            monthString=monNumArray[i];
        }
    }
    return [NSString stringWithFormat:@"%@-%@-%@",array[2],monthString,dayString];
}
-(void)useClassIdGetClassName:(NSInteger)classId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/class/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        for (NSDictionary*dict in array)
        {
            if([dict[@"id"] isEqualToNumber:[NSNumber numberWithInteger:classId]])
            {
                [_classBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
            }
        }
    } failure:^(NSError *error) {
    }];
}
-(void)useCourseIdGetCourseName:(NSInteger)courseId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/all"];
    NSArray*allCourseArray=[defaults objectForKey:@"userSid"];
    //NSLog(@"11--%@",allCourseArray);
    if(allCourseArray)
    {
        if([allCourseArray isKindOfClass:[NSArray class]])
        {
            for (NSDictionary*dict in allCourseArray)
            {
                if([dict[@"id"] isEqualToNumber:[NSNumber numberWithInteger:courseId]])
                {
                    [_courseBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
                }
            }
        }
        else
        {
            [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
                // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                
                NSArray*array=objString[@"data"];
                if(array)
                {
                    [defaults setObject:array forKey:@"teacherAllCourse"];
                    
                    for (NSDictionary*dict in array)
                    {
                        if([dict[@"id"] isEqualToNumber:[NSNumber numberWithInteger:courseId]])
                        {
                            [_courseBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
                        }
                    }
                }
            } failure:^(NSError *error) {
            }];
        }
    }
    else
    {
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSArray*array=objString[@"data"];
            if(array)
            {
                [defaults setObject:array forKey:@"teacherAllCourse"];
                
                for (NSDictionary*dict in array)
                {
                    if([dict[@"id"] isEqualToNumber:[NSNumber numberWithInteger:courseId]])
                    {
                        [_courseBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
                    }
                }
            }
        } failure:^(NSError *error) {
        }];
    }
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)setUpTitleLabel
{
    
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _bgView.backgroundColor=XXYBgColor;
    [self.view addSubview:_bgView];
    
    NSArray*arr=@[@"班  级:",@"课  程:",@"时  间:",@"标  题:",@"内  容:"];
    for(int i=0;i<5;i++)
    {
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, btnHight+i*(btnHight+40), 60, 40)];
        label.textAlignment=NSTextAlignmentRight;
        label.textColor=[UIColor colorWithRed:72.0/255 green:72.0/255 blue:72.0/255 alpha:1.0];
        label.text=arr[i];
        [_bgView addSubview:label];
    }
}
-(void)setUpBtns
{
    NSArray*placeHoder=@[@"请选择班级",@"请选择课程",@"请选择时间"];
    for(int i=0;i<3;i++)
    {
        UIButton*selBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        selBtn.frame=CGRectMake(65, btnHight+i*(btnHight+40), MainScreenW-75, 40);
        [selBtn setTitleColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] forState:UIControlStateNormal];
        [selBtn setTitle:placeHoder[i] forState:UIControlStateNormal];
        selBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);//上，左，下，右
        selBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        selBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
        selBtn.layer.cornerRadius=5;
        [selBtn setBackgroundColor:[UIColor whiteColor]];
        selBtn.titleLabel.font=[UIFont systemFontOfSize:17];
        [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        selBtn.tag=200+i;
        switch (i) {
            case 0:
                _classBtn=selBtn;
                break;
            case 1:
                _courseBtn=selBtn;
                break;
            case 2:
                _timeBtn=selBtn;
                break;
            default:
                break;
        }
        [_bgView addSubview:selBtn];
    }
    _titleTextField=[[UITextField alloc]init];
    _titleTextField.frame=CGRectMake(65, btnHight+3*(btnHight+40), MainScreenW-75, 40);
    [_titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _titleTextField.backgroundColor=[UIColor whiteColor];
    _titleTextField.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    
    _titleTextField.layer.cornerRadius=5;
    _titleTextField.delegate=self;
    _titleTextField.placeholder=@"请输入标题,20字以内";
    _titleTextField.tag=102;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    _titleTextField.leftView = view;
    _titleTextField.leftViewMode = UITextFieldViewModeAlways;

    [_bgView addSubview:_titleTextField];

    _contentTextView=[[UITextView alloc]initWithFrame:CGRectMake(65, btnHight+4*(btnHight+40), MainScreenW-75, 80)];
    _contentTextView.backgroundColor=[UIColor whiteColor];
    _contentTextView.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _contentTextView.layer.cornerRadius=5;
    _contentTextView.delegate=self;
    _contentTextView.font = [UIFont systemFontOfSize:17];
    [_bgView addSubview:_contentTextView];
    
    _placeHoderLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    _placeHoderLabel.textColor=[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] ;
    _placeHoderLabel.text = @" 请输入内容,200字以内";
    _placeHoderLabel.enabled=NO;
    _placeHoderLabel.alpha=0.5;
    [_contentTextView addSubview:_placeHoderLabel];
    
    _publishBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _publishBtn.frame=CGRectMake(20, btnHight*10+6*40, MainScreenW-40, 40);
    [_publishBtn addTarget:self action:@selector(publishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_publishBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    _publishBtn.layer.cornerRadius=5;
    [_publishBtn setTitle:@"立即发布" forState:UIControlStateNormal];
    [_bgView addSubview:_publishBtn];
}
-(void)sendPublishTypeName:(NSString *)title andIndex:(NSInteger)index andtypeId:(NSNumber *)typeId
{
    if(index==1)
    {
        [_classBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
       [_classBtn setTitle:title forState:UIControlStateNormal];
        self.classId=[typeId longValue];
        
        [self getUpCourseIdOfReloadNeData:[NSNumber numberWithLong:self.classId]];
//        NSLog(@"%li",self.classId);
    }
    if(index==3)
    {
        [_courseBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_courseBtn setTitle:title forState:UIControlStateNormal];
        self.courseId=[typeId longValue];
//        NSLog(@"%li",self.courseId);
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
            [_courseBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_courseBtn setTitle:dict[@"name"] forState:UIControlStateNormal];
            
            self.courseId=[dict[@"id"] longValue];
        }
    } failure:^(NSError *error) {}];
}

-(void)textViewDidChange:(UITextView *)textView
{
    self.contentTextView.text =  textView.text;
    if (textView.text.length == 0)
    {
        _placeHoderLabel.text = @" 请输入内容,200字以内";
    }
    else
    {
        _placeHoderLabel.text = @"";
    }
    
    if (textView.text.length > 200)
    {
        textView.text = [textView.text substringToIndex:200];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_titleTextField resignFirstResponder];
    [_contentTextView resignFirstResponder];
    [_datepicker removeFromSuperview];
    _datepicker = nil;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [_datepicker removeFromSuperview];
    _datepicker = nil;
    textView.layer.borderColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0].CGColor;
    textView.layer.borderWidth=2;
    
    [UIView animateWithDuration:0.5 animations:^{
        _bgView.frame=CGRectMake(0, -150, self.view.frame.size.width, self.view.frame.size.height);
    }];

    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    textView.layer.borderWidth=0.0;
    textView.layer.borderColor=[UIColor clearColor].CGColor;
    [UIView animateWithDuration:0.5 animations:^{
        _bgView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_datepicker removeFromSuperview];
    _datepicker = nil;
    textField.layer.borderColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0].CGColor;
    textField.layer.borderWidth=2;
    [UIView animateWithDuration:0.5 animations:^{
        _bgView.frame=CGRectMake(0, -100, self.view.frame.size.width, self.view.frame.size.height);
    }];

       return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
        textField.layer.borderWidth=0.0;
        textField.layer.borderColor=[UIColor clearColor].CGColor;
    [UIView animateWithDuration:0.5 animations:^{
        _bgView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];

    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return  [textField resignFirstResponder];
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.titleTextField)
    {
        if (textField.text.length > 20)
        {
            textField.text = [textField.text substringToIndex:20];
        }
    }
}

-(void)publishBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    _titleTextField.text= [_titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _contentTextView.text= [_contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.homeworkIndex==1)
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/homework/update"];

        
         if(_titleTextField.text.length==0)
        {
            [SVProgressHUD showErrorWithStatus:@"标题不能为空"];
        }
        else if (_contentTextView.text.length==0)
        {
            [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
        }
        else
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":[NSNumber numberWithLong:self.homeworkModel.classId],@"courseId":[NSNumber numberWithLong:self.homeworkModel.courseId],@"studyDate":_timeBtn.currentTitle,@"name":_titleTextField.text,@"description":_contentTextView.text,@"id":[NSNumber numberWithInteger:self.homeworkModel.uid]} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//            NSLog(@"%@",objString);
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
                {
                    [self.reloadDelegate reloadTableView];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
        }];

    }
    else
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/homework/create"];

        if(!_classId)
        {
            [SVProgressHUD showErrorWithStatus:@"请选择班级"];
        }
        else if (!_courseId)
        {
            [SVProgressHUD showErrorWithStatus:@"请选择课程"];
        }
        else if ([_timeBtn.currentTitle isEqualToString:@"请选择时间"])
        {
            [SVProgressHUD showErrorWithStatus:@"请选择时间"];
        }
        else if(_titleTextField.text.length==0)
        {
            [SVProgressHUD showErrorWithStatus:@"标题不能为空"];
        }
        else if (_contentTextView.text.length==0)
        {
            [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
        }
        
        else
        
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":[NSNumber numberWithLong:_classId],@"courseId":[NSNumber numberWithLong:_courseId],@"studyDate":_timeBtn.currentTitle,@"name":_titleTextField.text,@"description":_contentTextView.text} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if([objString[@"message"] isEqualToString:@"success"])
                
            {
                [SVProgressHUD showSuccessWithStatus:@"发布成功"];
                if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
                {
                    [self.reloadDelegate reloadTableView];
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        } failure:^(NSError *error) {
        }];

    }
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alert = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

//-(void)setUpAlertController:(NSString*)str
//{
//    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
//    {
//        if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
//        {
//            [self.reloadDelegate reloadTableView];
//        }
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//    [_alertCon addAction:action2];
//}
-(void)selBtnClicked:(UIButton*)btn
{
    XXYClassListController*classListC=[[XXYClassListController alloc]init];
    classListC.publishDelegate=self;
    if(btn.tag==200)
    {
        [_datepicker removeFromSuperview];
        _datepicker = nil;
        classListC.titleName=@"班级";
        classListC.index=1;
        [self.navigationController pushViewControllerWithAnimation:classListC];
    }
    if(btn.tag==201)
    {
        [_datepicker removeFromSuperview];
        _datepicker = nil;
        if(_classId)
        {
            classListC.titleName=@"课程";
            classListC.classOfId=[NSNumber numberWithLong:_classId];
            classListC.index=3;
            [self.navigationController pushViewControllerWithAnimation:classListC];
        }
        else
        {
            [self setUpAlertController:@"请先选择班级"];
        }
    }
    if(btn.tag==202)
    {
        if(!_datepicker)
        {
            [self setUpDatePicker];
        }
        else
        {
            [_datepicker removeFromSuperview];
            _datepicker = nil;
        }
    }
}
-(void)setUpDatePicker
{
    _datepicker = [[UIDatePicker alloc] init];
    _datepicker.backgroundColor=[UIColor whiteColor];
    _datepicker.datePickerMode = UIDatePickerModeDate;
    _datepicker.minimumDate=[NSDate date];
    _datepicker.frame = CGRectMake(0, self.view.frame.size.height, 0, 0);
    [self.view addSubview:_datepicker];
    
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-216.0f, [UIScreen mainScreen].bounds.size.width, 216);
    }];
    [_timeBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_timeBtn setTitle:[self getDateStr:_datepicker.date] forState:UIControlStateNormal];
//    _birthField.text = [self getDateStr:_datepicker.date];
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
}
- (void)changeDate:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSDate *date = datePicker.date;
    [_timeBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_timeBtn setTitle:[self getDateStr:date] forState:UIControlStateNormal];
}
// 获取日期键盘的日期
- (NSString *)getDateStr:(NSDate *)date
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    return dateStr;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
