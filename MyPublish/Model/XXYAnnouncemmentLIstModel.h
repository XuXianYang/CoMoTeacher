#import "JSONModel.h"

@interface XXYAnnouncemmentLIstModel : JSONModel

@property(nonatomic,assign)NSInteger uid;

@property(nonatomic,assign)NSInteger classId;

@property(nonatomic,assign)NSInteger createdBy;

@property(nonatomic,assign)NSInteger schoolId;

@property(nonatomic,assign)NSInteger type;


@property(nonatomic,copy)NSString*content;

@property(nonatomic,copy)NSString*createdAt;


@property(nonatomic,copy)NSString* enrolYear;

@property(nonatomic,copy)NSString *title;


@end
