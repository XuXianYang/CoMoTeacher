#import "XXYPublishCoursewareController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"
#import "XXYClassListController.h"
#import "AFNetworking.h"
#import "RequestPostUploadHelper.h"

#define btnHight (MainScreenH-64-40*7)/15

@interface XXYPublishCoursewareController ()<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,XXYPublishContentTypeListDelegate>
{
    UIAlertController *_alertCon;

}
@property(nonatomic,strong)UIButton*receiverTextField;
@property(nonatomic,strong)UIButton*courseNameTextField;
@property(nonatomic,strong)UIButton*typeTextField;
//@property(nonatomic,strong)UITextField*titleTextField;
@property(nonatomic,strong)UITextView*contentTextView;
@property(nonatomic,strong)UIButton*courseTextField;
@property(nonatomic,strong)UIButton*publishBtn;
@property(nonatomic,strong)UILabel*placeHoderLabel;
@property(nonatomic,strong)UIImage*selImage;
@property(nonatomic,strong)NSNumber* courseType;
@property(nonatomic,strong)NSNumber* courseId;
@property(nonatomic,strong)NSNumber* classId;
@property(nonatomic,copy)NSString* picName;


@property(nonatomic,strong)UIView* bgView;


@end

@implementation XXYPublishCoursewareController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.title=self.titleName;;
    self.view.backgroundColor=XXYBgColor;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpSubViews];
    
    if(self.courseListModelIndex==1)
    {
        [_receiverTextField setTitle:self.courseListModel.className forState:UIControlStateNormal];
        [_typeTextField setTitle:[NSString stringWithFormat:@"%@",[self turnCourseWareCategoryNumToName:self.courseListModel.type]] forState:UIControlStateNormal];
        _classId=[NSNumber numberWithInteger:self.courseListModel.classId];
        _courseType=[NSNumber numberWithInteger:self.courseListModel.type];
        [_courseTextField setTitle:self.courseListModel.name forState:UIControlStateNormal];
        
        [_receiverTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_typeTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_courseNameTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_courseTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        
        if(self.courseListModel.myDescription)
        {
            _placeHoderLabel.text=nil;
            _contentTextView.text=self.courseListModel.myDescription;
        }
        
        _courseId=[NSNumber numberWithInteger:self.courseListModel.courseId];
        
        [self useCourseIdGetCourseName:_courseId.integerValue];
        [_publishBtn setTitle:@"修改课件" forState:UIControlStateNormal];
    }
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
                    [_courseNameTextField setTitle:dict[@"name"] forState:UIControlStateNormal];
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
                            [_courseNameTextField setTitle:dict[@"name"] forState:UIControlStateNormal];
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
                        [_courseNameTextField setTitle:dict[@"name"] forState:UIControlStateNormal];
                    }
                }
            }
        } failure:^(NSError *error) {
        }];
    }
}
-(NSString*)turnCourseWareCategoryNumToName:(NSInteger)categoryNum;
{
    NSArray*array=@[@"预习向导",@"课堂笔记",@"课件"];
    NSString*categoryName;
    
    for(NSInteger i=1;i<4;i++)
    {
        if(categoryNum==i)
        {
            categoryName=array[i-1];
        }
    }
    return categoryName;
}
-(void)setUpSubViews
{
    
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _bgView.backgroundColor=XXYBgColor;
    [self.view addSubview:_bgView];
    
    NSArray*arr=@[@"班  级:",@"课  程:",@"类  型:",@"内  容:",@"课  件:"];
        for(int i=0;i<5;i++)
    {
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, btnHight+i*(btnHight+40), 60, 40)];
        if(i==4)
            label.frame=CGRectMake(0, 5*btnHight+40*5, 60, 40);
        label.textAlignment=NSTextAlignmentRight;
        label.text=arr[i];
        label.textColor=[UIColor colorWithRed:72.0/255 green:72.0/255 blue:72.0/255 alpha:1.0];
        [_bgView addSubview:label];
    }
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
//    _titleTextField.leftView = view;
//    _titleTextField.leftViewMode = UITextFieldViewModeAlways;
    
    NSArray*placeHoder=@[@" 请选择班级",@" 请选择课程",@" 请选择课件类型",@" 请选择课件"];
    for(int i=0;i<4;i++)
    {
        UIButton*textField=[UIButton buttonWithType:UIButtonTypeSystem];
        textField.frame=CGRectMake(65, i*(btnHight+40)+btnHight, MainScreenW-75, 40);
        [textField setBackgroundColor:[UIColor whiteColor]];
        [textField setTitle:placeHoder[i] forState:UIControlStateNormal];
        [textField setTitleColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] forState:UIControlStateNormal];
        textField.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);//上，左，下，右
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        textField.titleLabel.textAlignment=NSTextAlignmentLeft;
        textField.titleLabel.font=[UIFont systemFontOfSize:17];
        [textField addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        textField.layer.cornerRadius=5;

        textField.tag=200+i;
        
        switch (i) {
            case 0:
                _receiverTextField=textField;
                break;
            case 2:
                _typeTextField=textField;
                break;
            case 1:
                _courseNameTextField=textField;
                break;
            case 3:
                _courseTextField=textField;
                textField.frame=CGRectMake(65,5*btnHight+40*5, MainScreenW-75, 40);
                break;
            default:
                break;
        }
        [_bgView addSubview:textField];
    }
    _contentTextView=[[UITextView alloc]initWithFrame:CGRectMake(65, btnHight*4+40*3, MainScreenW-75, 80)];
    _contentTextView.backgroundColor=[UIColor whiteColor];
    _contentTextView.layer.cornerRadius=5;
    _contentTextView.delegate=self;
    _contentTextView.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _contentTextView.font = [UIFont systemFontOfSize:17];
    [_bgView addSubview:_contentTextView];

    _placeHoderLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    _placeHoderLabel.textColor=[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0];
    _placeHoderLabel.text = @"  请输入内容,100字以内";
    _placeHoderLabel.enabled=NO;
    _placeHoderLabel.alpha=0.5;
    [_contentTextView addSubview:_placeHoderLabel];
    
    _publishBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _publishBtn.frame=CGRectMake(20, 10*btnHight+40*6, MainScreenW-40, 40);
    [_publishBtn addTarget:self action:@selector(publishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_publishBtn setBackgroundColor:[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0]];
    _publishBtn.layer.cornerRadius=5;
    [_publishBtn setTitle:@"立即发布" forState:UIControlStateNormal];
    [_bgView addSubview:_publishBtn];
}
-(void)selBtnClicked:(UIButton*)btn
{
    if(btn.tag==203)
    {
        UIAlertController*al=[UIAlertController alertControllerWithTitle:@"请选择文件来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            [self pickPicture:UIImagePickerControllerSourceTypeCamera];
        }];
        [al addAction:action1];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                  {
                                      [self pickPicture:UIImagePickerControllerSourceTypePhotoLibrary];
                                  }];
        [al addAction:action2];
        UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消 " style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                                  {
                            }];
        [al addAction:action4];
    [self presentViewController:al animated:YES completion:nil];
    }
    else
    {
        
        XXYClassListController*classListC=[[XXYClassListController alloc]init];
        classListC.publishDelegate=self;
        if(btn.tag==200)
        {
            classListC.titleName=@"班级";
            classListC.index=1;
            [self.navigationController pushViewControllerWithAnimation:classListC];
        }
        if(btn.tag==202)
        {
            classListC.titleName=@"课件类型";
            classListC.index=2;
            [self.navigationController pushViewControllerWithAnimation:classListC];
        }
        if(btn.tag==201)
        {
            if(_classId)
            {
                classListC.titleName=@"课程";
                classListC.classOfId=_classId;
                

                classListC.index=3;
                [self.navigationController pushViewControllerWithAnimation:classListC];
            }
            else
            {
                [self setUpAlertController:@"请先选择班级"];
            }
        }
    }
}
-(void)sendPublishTypeName:(NSString *)title andIndex:(NSInteger)index andtypeId:(NSNumber *)typeId
{
    if(index==2)
    {
       
        [_typeTextField setTitle:title forState:UIControlStateNormal];
        [_typeTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        _courseType=typeId;
    }
    if(index==1)
    {
        [_receiverTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        
        [_receiverTextField setTitle:title forState:UIControlStateNormal];
        _classId=typeId;
        
        [self getUpCourseIdOfReloadNeData:_classId];
    }
    if(index==3)
    {
        [_courseNameTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_courseNameTextField setTitle:title forState:UIControlStateNormal];
        _courseId=typeId;
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
            [_courseNameTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_courseNameTextField setTitle:dict[@"name"] forState:UIControlStateNormal];
            _courseId=dict[@"id"];
        }
    } failure:^(NSError *error) {}];
}
-(void)pickPicture:(UIImagePickerControllerSourceType)sourceType
{
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{
    
        if(![XXYMyTools isCameraValid]&&sourceType==1)
        {
            [SVProgressHUD showErrorWithStatus:@"如果不能访问相机,请在iPhone的“设置-隐私-相机”选项中，允许程序访问你的相机"];
        }
        if(sourceType==0)
        {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        }

    
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    _selImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    // 设置上传图片的名字
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    self.picName=fileName;
     [_courseTextField setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_courseTextField setTitle:fileName forState:UIControlStateNormal];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}
-(void)textViewDidChange:(UITextView *)textView
{
    self.contentTextView.text =  textView.text;
    if (textView.text.length == 0)
    {
        _placeHoderLabel.text = @"  请输入内容,100字以内";
    }
    else
    {
        _placeHoderLabel.text = @"";
    }
    if (textView.text.length > 100)
    {
        textView.text = [textView.text substringToIndex:100];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_contentTextView resignFirstResponder];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.layer.borderColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0].CGColor;
    textView.layer.borderWidth=2;
    [UIView animateWithDuration:0.5 animations:^{
        _bgView.frame=CGRectMake(0, -120, self.view.frame.size.width, self.view.frame.size.height);
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
-(void)publishBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    _contentTextView.text= [_contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.courseListModelIndex==1)
    {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/material/update"];
        
        if(_contentTextView.text.length==0)
        {
            [SVProgressHUD showErrorWithStatus:@"课件内容不能为空"];
        }

       else if(_classId&&_courseId)
            [manager POST:requestUrl parameters:@{@"sid":userSidString,@"classId":_classId,@"courseId":_courseId,@"type":_courseType,@"name":_courseTextField.currentTitle,@"description":_contentTextView.text,@"id":[NSNumber numberWithInteger:self.courseListModel.uid]} progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
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
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        }];
    }
    else
    {
        // 获取图片数据
        NSData *fileData = UIImageJPEGRepresentation(_selImage, 0.2);
        
        // 获得网络管理者
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        manager.responseSerializer=[AFHTTPResponseSerializer serializer];
        
        NSString*urlString=[NSString stringWithFormat:@"%@/teacher/course/material/upload?sid=%@",BaseUrl,userSidString];
        
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
       
        
        
        
//        parameters:@{@"sid":userSidString,@"classId":_classId,@"resourceFileId":num,@"courseId":courseId,@"type":_courseType,@"name":name,@"description":_contentTextView.text}
        
        if(!_classId)
        {
            [SVProgressHUD showErrorWithStatus:@"请选择班级"];
        }
        else if (!_courseId)
        {
            [SVProgressHUD showErrorWithStatus:@"请选择课程"];
        }
        else if (!_courseType)
        {
            [SVProgressHUD showErrorWithStatus:@"请选择课件类型"];
        }
        else if(_contentTextView.text.length==0)
        {
            [SVProgressHUD showErrorWithStatus:@"课件内容不能为空"];
        }
      else if (self.picName.length<=0)
      {
          [SVProgressHUD showErrorWithStatus:@"请选择课件"];
      }

        else
        [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
            if (fileData != nil)
            {
                if(self.picName)
                [formData appendPartWithFileData:fileData name:@"file" fileName:self.picName mimeType:@"image/jpg"];
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                NSNumber*num=objString[@"data"];
                [self setUpAlertControllerForUploadMaterial:num AndName:self.picName AndCourseId:_courseId];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"上传课件失败"];
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           // NSLog(@"error=%@",error.localizedDescription);
            [SVProgressHUD showSuccessWithStatus:@"上传课件失败"];
        }];
    }
}
-(void)creatCourseMaterial:(NSNumber*)num AndName:(NSString*)name AndCourseId:(NSNumber*)courseId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/material/create"];
    if(courseId&&_classId)
    {
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"classId":_classId,@"resourceFileId":num,@"courseId":courseId,@"type":_courseType,@"name":name,@"description":_contentTextView.text} success:^(id responseObject){
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
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"发布失败"];
               
            }
        } failure:^(NSError *error) {
            [SVProgressHUD showSuccessWithStatus:@"发布失败"];        }];
    }
}

-(void)setUpAlertControllerForUploadMaterial:(NSNumber*)num AndName:(NSString*)name AndCourseId:(NSNumber*)courseId
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"上传课程材料附件成功" message:@"是否发布课件?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [action1 setValue:[UIColor colorWithRed:10.0/255 green:188.0/255 blue:180.0/255 alpha:1] forKey:@"titleTextColor"];
    [alertCon addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self creatCourseMaterial:num AndName:name AndCourseId:courseId];
        
          }];
    //label.textColor = [UIColor colorWithRed:139.0/255 green:178.0/255 blue:38.0/255 alpha:1]; //里面
    [action2 setValue:[UIColor colorWithRed:10.0/255 green:188.0/255 blue:180.0/255 alpha:1] forKey:@"titleTextColor"];
    [alertCon addAction:action2];
    [self presentViewController:alertCon animated:YES completion:nil];

}
-(void)setUpAlertController:(NSString*)str
{
    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_alertCon animated:YES completion:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:_alertCon repeats:NO];
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
-(void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
