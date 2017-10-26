#import "XXYCourseWarelListCell.h"
#import "XXYCourseWareListModel.h"
#import "BSHttpRequest.h"
@interface XXYCourseWarelListCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleContent;
@property (weak, nonatomic) IBOutlet UILabel *className;
@property (weak, nonatomic) IBOutlet UILabel *coursewareStyle;
@property (weak, nonatomic) IBOutlet UILabel *publishTime;


@end

@implementation XXYCourseWarelListCell
-(void)setDataModel:(XXYCourseWareListModel *)dataModel
{
    _dataModel=dataModel;
    
    
    NSString *_test  =dataModel.myDescription;
    NSMutableParagraphStyle *paraStyle01 = [[NSMutableParagraphStyle alloc] init];
    paraStyle01.alignment = NSTextAlignmentLeft;  //对齐
    paraStyle01.headIndent = 0.0f;//行首缩进
    //参数：（字体大小17号字乘以2，34f即首行空出两个字符）
    CGFloat emptylen = self.titleContent.font.pointSize * 2;
    paraStyle01.firstLineHeadIndent = emptylen;//首行缩进
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:_test attributes:@{NSParagraphStyleAttributeName:paraStyle01}];
    
    _titleContent.attributedText=attrText;
    
    [self useCourseIdGetCourseName:dataModel.courseId and:dataModel.className];
    
    _coursewareStyle.text=[NSString stringWithFormat:@"%@",[self turnCourseWareCategoryNumToName:dataModel.type]];
    _publishTime.text=[self turnDateStringToMyString:dataModel.createdAt];
}
-(void)layoutSubviews
{
    _titleContent.textAlignment=NSTextAlignmentLeft;
    _titleContent.numberOfLines=0;
    _className.textAlignment=NSTextAlignmentLeft;
    _coursewareStyle.textAlignment=NSTextAlignmentRight;
    _publishTime.textAlignment=NSTextAlignmentLeft;
    _publishTime.font=[UIFont systemFontOfSize:15];
    
    _titleContent.textColor=XXYCharactersColor;
    _className.textColor=XXYCharactersColor;
    _coursewareStyle.textColor=XXYCharactersColor;
    _publishTime.textColor=[UIColor lightGrayColor];
}
-(void)useCourseIdGetCourseName:(NSInteger)courseId and:(NSString*)className
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/teacher/course/all"];
    
    NSArray*allCourseArray=[defaults objectForKey:@"userSid"];
    if(allCourseArray)
    {
        if([allCourseArray isKindOfClass:[NSArray class]])
        {
            for (NSDictionary*dict in allCourseArray)
            {
                if([dict[@"id"] isEqualToNumber:[NSNumber numberWithInteger:courseId]])
                {
                    _className.text=[NSString stringWithFormat:@"%@-%@",className,dict[@"name"]];
                }
            }
            
        }
        else
        {
            [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
                
                id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                
                NSArray*array=objString[@"data"];
                if(array)
                {
                    [defaults setObject:array forKey:@"teacherAllCourse"];
                    
                    for (NSDictionary*dict in array)
                    {
                        if([dict[@"id"] isEqualToNumber:[NSNumber numberWithInteger:courseId]])
                        {
                            _className.text=[NSString stringWithFormat:@"%@-%@",className,dict[@"name"]];
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
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSArray*array=objString[@"data"];
            if(array)
            {
                [defaults setObject:array forKey:@"teacherAllCourse"];
                
                for (NSDictionary*dict in array)
                {
                    if([dict[@"id"] isEqualToNumber:[NSNumber numberWithInteger:courseId]])
                    {
                        _className.text=[NSString stringWithFormat:@"%@-%@",className,dict[@"name"]];
                        
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
    
    if(array.count>=4)
        return [NSString stringWithFormat:@"%@-%@-%@ %@",array[2],monthString,dayString,array[3]];
    else
        return @"";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
