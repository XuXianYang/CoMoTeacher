#import "XXYPublishAnnouncementController.h"
#import "XXYBackButton.h"
#import"XXYClassListController.h"
#import"BSHttpRequest.h"
@interface XXYPublishAnnouncementController ()<UITextViewDelegate,UITextFieldDelegate,XXYPublishContentTypeListDelegate>

@property(nonatomic,strong)UIButton*classBtn;
@property(nonatomic,strong)UITextField*titleTextField;
@property(nonatomic,strong)UITextView*contentTextView;
@property(nonatomic,strong)UIButton*publishBtn;
@property(nonatomic,strong)UILabel*placeHoderLabel;
@property(nonatomic,assign)long classId;
@property(nonatomic,strong)UIView* bgView;

@end

@implementation XXYPublishAnnouncementController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.publishAnnouncemmentTitle;
    self.view.backgroundColor=XXYBgColor;
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    [self setupSubViews];
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    
    if(self.announcemmentIndex==1)
    {
        [_classBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_classBtn setTitle:self.classBtnName forState:UIControlStateNormal];
        _titleTextField.text=self.announcemmentModel.title;
        _contentTextView.text=self.announcemmentModel.content;
        _placeHoderLabel.text=nil;
        [_publishBtn setTitle:@"修改公告" forState:UIControlStateNormal];
    }
}

-(void)setupSubViews
{
    
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _bgView.backgroundColor=XXYBgColor;
    [self.view addSubview:_bgView];

    NSArray*arr=@[@"班  级:",@"标  题:",@"内  容:"];
    for(int i=0;i<3;i++)
    {
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 20+i*60, 60, 40)];
        label.textAlignment=NSTextAlignmentRight;
        label.textColor=[UIColor colorWithRed:72.0/255 green:72.0/255 blue:72.0/255 alpha:1.0];
        label.text=arr[i];
        [_bgView addSubview:label];
    }
    
    
    
    _titleTextField=[[UITextField alloc]init];
    _titleTextField.frame=CGRectMake(65, 80, MainScreenW-75, 40);
    [_titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _titleTextField.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _titleTextField.layer.cornerRadius=5;
    _titleTextField.textAlignment=NSTextAlignmentLeft;
    _titleTextField.backgroundColor=[UIColor whiteColor];
    _titleTextField.delegate=self;
    _titleTextField.placeholder=@"请输入标题,20字以内";
    _titleTextField.tag=102;
    [_bgView addSubview:_titleTextField];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    _titleTextField.leftView = view;
    _titleTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton*selBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    selBtn.frame=CGRectMake(65, 20, MainScreenW-75, 40);
    selBtn.layer.cornerRadius=5;
    [selBtn setBackgroundColor:[UIColor whiteColor]];
    [selBtn setTitle:@"请选择班级" forState:UIControlStateNormal];
    [selBtn setTitleColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] forState:UIControlStateNormal];
    selBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);//上，左，下，右
    selBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    selBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    selBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    selBtn.tag=200;
    _classBtn=selBtn;
    [_bgView addSubview:selBtn];
    
    _contentTextView=[[UITextView alloc]initWithFrame:CGRectMake(65, 140, MainScreenW-75, 90)];
    _contentTextView.layer.cornerRadius=5;
    _contentTextView.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _contentTextView.backgroundColor=[UIColor whiteColor];
    _contentTextView.delegate=self;
    _contentTextView.font = [UIFont systemFontOfSize:17];
    [_bgView addSubview:_contentTextView];
    
    _placeHoderLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    _placeHoderLabel.textColor=[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] ;
    _placeHoderLabel.text = @" 请输入内容,100字以内";
    _placeHoderLabel.enabled=NO;
    _placeHoderLabel.alpha=0.5;
    [_contentTextView addSubview:_placeHoderLabel];
    
    _publishBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _publishBtn.frame=CGRectMake(20, 300, MainScreenW-40, 40);
    [_publishBtn addTarget:self action:@selector(publishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _publishBtn.layer.cornerRadius=5;
    [_publishBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];

    [_publishBtn setTitle:@"立即发布" forState:UIControlStateNormal];
    [_bgView addSubview:_publishBtn];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)textViewDidChange:(UITextView *)textView
{
    self.contentTextView.text =  textView.text;
    if (textView.text.length == 0)
    {
        _placeHoderLabel.text = @" 请输入内容,100字以内";
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
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.layer.borderColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0].CGColor;
    textView.layer.borderWidth=2;
    [UIView animateWithDuration:0.5 animations:^{
        _bgView.frame=CGRectMake(0, -50, self.view.frame.size.width, self.view.frame.size.height);
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
    textField.layer.borderColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0].CGColor;
    textField.layer.borderWidth=2;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    textField.layer.borderWidth=0.0;
    textField.layer.borderColor=[UIColor clearColor].CGColor;
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
    if(_titleTextField.text.length==0)
    {
        [SVProgressHUD showErrorWithStatus:@"标题不能为空"];
    }
    else if (_contentTextView.text.length==0)
    {
        [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
    }
    else if(self.announcemmentIndex==1)
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/announcement/update"];

        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":[NSNumber numberWithLong:_classId],@"type":@3,@"title":_titleTextField.text,@"content":_contentTextView.text,@"id":[NSNumber numberWithInteger:self.announcemmentModel.uid]} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
                {
                    [self.reloadDelegate reloadTableView];
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"您可能没有权限或者其他原因,修改失败"];
            }
        } failure:^(NSError *error) {
        
            [SVProgressHUD showSuccessWithStatus:@"修改失败"];
        }];
    }
    else
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/announcement/create"];

        if(_classId<=0)
        {
            [SVProgressHUD showSuccessWithStatus:@"请选择班级"];
        }
        else
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":[NSNumber numberWithLong:_classId],@"type":@3,@"title":_titleTextField.text,@"content":_contentTextView.text} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
            
            NSString*codeStr=objString[@"code"];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [SVProgressHUD showSuccessWithStatus:@"发布成功"];
                if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
                {
                    [self.reloadDelegate reloadTableView];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            if(codeStr.integerValue==4001)
            {
               [SVProgressHUD showSuccessWithStatus:@"您可能没有权限,发布失败"];
            }
        } failure:^(NSError *error) {
        
             [SVProgressHUD showSuccessWithStatus:@"发布失败"];
        }];
    }
}

-(void)sendPublishTypeName:(NSString *)title andIndex:(NSInteger)index andtypeId:(NSNumber *)typeId
{
    if(index==1)
    {
        [_classBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_classBtn setTitle:title forState:UIControlStateNormal];
        _classId=[typeId longValue];
    }
}
-(void)selBtnClicked:(UIButton*)btn
{
    XXYClassListController*classListC=[[XXYClassListController alloc]init];
            classListC.titleName=@"班级";
    classListC.publishDelegate=self;
    classListC.index=1;
    [self.navigationController pushViewControllerWithAnimation:classListC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}@end
