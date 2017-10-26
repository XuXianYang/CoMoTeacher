#import "JSONModel.h"

@interface XXYHomeworkListOfCheckModel : JSONModel
//{"homeworkId":24,"studentId":22,"studyDate":"Nov 21, 2016 12:00:00 AM","reviewTime":"Nov 21, 2016 6:58:44 PM","createdBy":59,"createdAt":"Nov 21, 2016 6:58:44 PM","studentName":"孩子","parentName":"家长","strReviewTime":"2016-11-21 18:58","isSign":true}

@property(nonatomic,assign)NSInteger homeworkId;

@property(nonatomic,assign)NSInteger studentId;

@property(nonatomic,assign)NSInteger createdBy;


@property(nonatomic,copy)NSString*studyDate;

@property(nonatomic,copy)NSString*reviewTime;

@property(nonatomic,copy)NSString*createdAt;

@property(nonatomic,copy)NSString* parentName;

@property(nonatomic,copy)NSString *strReviewTime;

@property(nonatomic,copy)NSString *studentName;

@property(nonatomic,assign)BOOL isSign;

@end
