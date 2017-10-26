#import "XXYMyInfoController.h"
#import "XXYInfoSettingController.h"
#import "AFNetworking.h"
#import "CropImageViewController.h"
#import "BSHttpRequest.h"
#import "UIImageView+WebCache.h"
#import "XXYSettingDetailController.h"
@interface XXYMyInfoController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIAlertController *_alertCon;
}
@property(nonatomic,strong)UIImage*selImage;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIImageView*iconImageView;
@property(nonatomic,strong)UIView*bgIconImageView;
@property(nonatomic,strong)UIView*bgTableView;
@property(nonatomic,strong)UIButton*settingBtn;
@property(nonatomic,strong)UILabel*nameLabel;

@end

@implementation XXYMyInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"";
    self.view.backgroundColor=XXYBgColor;
    [self setUpSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name: @"CropOK" object: nil];
    [self getUpNewData];
}
-(void)getUpNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [self.dataList removeAllObjects];
        
        NSString*realName=@"";
        if(objString[@"data"][@"realName"])
        {
            realName=objString[@"data"][@"realName"];
        }
        else
        {
            realName=@"请填写姓名";
        }
        self.dataList=[NSMutableArray arrayWithArray:@[[NSString stringWithFormat:@"%@%@",@"学校:",objString[@"data"][@"teacherInfo"][@"schoolName"]],[NSString stringWithFormat:@"%@%@",@"手机:",objString[@"data"][@"mobileNo"]],[NSString stringWithFormat:@"%@%@",@"姓名:",realName]]];
        
         [BSHttpRequest archiverObject:self.dataList ByKey:@"personnalInfoList" WithPath:@"personnalInfoList.plist"];
        
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:objString[@"data"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"iconOfUserHead.jpg"]];
        
        _nameLabel.text=realName;
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
    
        self.dataList =[BSHttpRequest unarchiverObjectByKey:@"personnalInfoList" WithPath:@"personnalInfoList.plist"];
        [self.tableView reloadData];
    }];
}
-(void)setUpSubViews
{
    // 状态栏(statusbar)
    CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
    //标题栏
    CGRect NavRect = self.navigationController.navigationBar.frame;
    CGFloat scrollowTop=NavRect.size.height+StatusRect.size.height;
    
    UIScrollView*scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,-scrollowTop, MainScreenW, MainScreenH)];
    scrollView.backgroundColor=XXYBgColor;
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.scrollEnabled=NO;
    scrollView.bounces=NO;
    scrollView.contentSize=CGSizeMake(0, MainScreenH);
    [self.view addSubview:scrollView];
    
    _bgIconImageView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenH*1/3+20)];
    _bgIconImageView.backgroundColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
    [scrollView addSubview:_bgIconImageView];
    
    _bgTableView=[[UIView alloc]initWithFrame:CGRectMake(12, MainScreenH*1/3-25+20, MainScreenW-24, 170)];
    _bgTableView.backgroundColor=[UIColor whiteColor];
    [scrollView addSubview:_bgTableView];
    
    [_bgTableView addSubview:self.tableView];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.bounces=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    _settingBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [_settingBtn addTarget:self action:@selector(settingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _settingBtn.frame=CGRectMake(12, MainScreenH*1/3+205, MainScreenW-24, 50);
    [_settingBtn setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:_settingBtn];
    
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    imageView.image=[UIImage imageNamed:@"settingiocn"];;
    [_settingBtn addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, 50)];
    label.text=@"设置";
    label.textColor=XXYCharactersColor;
    label.font=[UIFont systemFontOfSize:16];
    [_settingBtn addSubview:label];
    
    UIImageView*indicatorImageView=[[UIImageView alloc]initWithFrame:CGRectMake(_settingBtn.frame.size.width-40, 15, 20, 20)];
    indicatorImageView.image=[UIImage imageNamed:@"Indicator"];;
    [_settingBtn addSubview:indicatorImageView];
    
    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-100)/2,50, 100, 100)];
    _iconImageView.backgroundColor=[UIColor lightGrayColor];
    [_bgIconImageView addSubview:_iconImageView];
    //[_iconImageView sd_setImageWithURL:[NSURL URLWithString:userInfoDict[@"user"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"iconOfUserHead"]];
    _iconImageView.image=[UIImage imageNamed:@"iconOfUserHead.jpg"];
    _iconImageView.layer.cornerRadius=50;
    _iconImageView.layer.masksToBounds=YES;
    _iconImageView.userInteractionEnabled=YES;
    _iconImageView.contentMode=UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer * pictureTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAvatarView:)];
    [_iconImageView addGestureRecognizer:pictureTap];
    
    _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,50+_iconImageView.frame.size.width+5, MainScreenW, 30)];
    _nameLabel.font=[UIFont systemFontOfSize:18];
    _nameLabel.text=@"";
    _nameLabel.textAlignment=NSTextAlignmentCenter;
    _nameLabel.textColor=[UIColor whiteColor];
    _nameLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapNameClieked:)];
    [_nameLabel addGestureRecognizer:tap];
    [_bgIconImageView addSubview:_nameLabel];
}
-(void)tapNameClieked:(UITapGestureRecognizer*)tap
{
    XXYSettingDetailController*detailCon=[[XXYSettingDetailController alloc]init];
    detailCon.titleName=@"个人资料";
    detailCon.index=2;
    detailCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewControllerWithAnimation:detailCon];
}
-(void)tapAvatarView:(UITapGestureRecognizer*)tap
{
    UIAlertController*al=[UIAlertController alertControllerWithTitle:@"请选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIPopoverPresentationController *popover = al.popoverPresentationController;
    
    if (popover) {
        
        popover.sourceView = _iconImageView;
        popover.sourceRect = _iconImageView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
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
    
    //NSLog(@"imageInfo=%@",info);
    _selImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    _selImage=[XXYMyTools fixOrientation:_selImage];
    CropImageViewController*cropCon=[[CropImageViewController alloc]init];
    cropCon.image=_selImage;
    cropCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cropCon animated:NO];
}
- (void)notificationHandler: (NSNotification *)notification {
    UIImage*image = notification.object;
    [self uploadPicture:image];
}

//保存图片
//- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
//{
//    NSData* imageData = UIImagePNGRepresentation(tempImage);
//    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* totalPath = [documentPath stringByAppendingPathComponent:imageName];
//
//    //保存到 document
//    [imageData writeToFile:totalPath atomically:NO];
//}
//从document取得图片
//- (UIImage *)getImage:(NSString *)urlStr
//{
//    return [UIImage imageWithContentsOfFile:urlStr];
//}
-(void)uploadPicture:(UIImage*)image
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    // 获取图片数据
    NSData *fileData = UIImageJPEGRepresentation(image, 0.2);
    // 设置上传图片的名字
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    NSString*urlString=[NSString stringWithFormat:@"%@/user/avatar/upload?sid=%@",BaseUrl,userSidString];
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSNumber*imageWidth=[NSNumber numberWithFloat:image.size.width-1];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"topX"] = @0;
    parameter[@"topY"] = @0;
    parameter[@"width"] = imageWidth;
    [manager POST:urlString parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (fileData != nil)
        {
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"image/jpg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            _iconImageView.image=_selImage;
            [self setUpAlertController:@"更换头像成功"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
        else
        {
            [self setUpAlertController:objString[@"message"]];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       // NSLog(@"error=%@",error.localizedDescription);
        [self setUpAlertController:@"更换头像失败"];
        [self presentViewController:_alertCon animated:YES completion:nil];
    }];
}
-(void)setUpAlertController:(NSString*)str
{
    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [_alertCon addAction:action2];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
}
-(void)settingBtnClicked:(UIButton*)btn
{
    XXYInfoSettingController*settingCon=[[XXYInfoSettingController alloc]init];
    settingCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewControllerWithAnimation:settingCon];
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
    cell.accessoryType=UITableViewCellAccessoryNone;
    cell.textLabel.text=self.dataList[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:14];
    cell.textLabel.textColor=XXYCharactersColor;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==2)
    {
        [self tapNameClieked:nil];
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    imageView.image=[UIImage imageNamed:@"infoicon"];;
    [view addSubview:imageView];
    
    UILabel*lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,49,_bgTableView.frame.size.width, 1)];
    lineLabel.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    [view addSubview:lineLabel];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, 50)];
    label.text=@"个人信息";
    label.textColor=XXYCharactersColor;
    label.font=[UIFont systemFontOfSize:16];
    [view addSubview:label];
    return view;
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,_bgTableView.frame.size.width, 170) style:UITableViewStylePlain];
        _tableView.backgroundColor=[UIColor whiteColor];
    }
    return _tableView;
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray arrayWithArray:@[@"学校:",@"手机:",@"姓名:"]];
    }
    return _dataList;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self getUpNewData];
}
-(void)viewDidAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationItem.title=@"";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
