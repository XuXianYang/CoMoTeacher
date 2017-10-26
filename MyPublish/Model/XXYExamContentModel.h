#import "JSONModel.h"

@interface XXYExamContentModel : JSONModel

//course
@property(nonatomic,assign)NSInteger courseId;
@property(nonatomic,copy)NSString*courseName;

//quiz
@property(nonatomic,assign)NSInteger uid;
@property(nonatomic,assign)NSInteger category;
@property(nonatomic,assign)NSInteger daysAfterNow;

@property(nonatomic,assign)NSInteger studyMonth;
@property(nonatomic,assign)NSInteger studyTerm;
@property(nonatomic,assign)NSInteger studyYear;

@property(nonatomic,copy)NSString* startTime;
@property(nonatomic,copy)NSString*endTime;
@property(nonatomic,copy)NSString*enrolYear;
@property(nonatomic,copy)NSString*myDescription;
@property(nonatomic,copy)NSString* name;

@end
