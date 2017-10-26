#import "JSONModel.h"

@interface XXYCourseWareListModel : JSONModel
//{"id":9,"type":3,"createdAt":"Nov 23, 2016 1:37:00 PM","name":"eclipse.exe","description":"额瓦斯","classInfo":{"classId":7,"className":"2016届(5)班"}}],"pagingInfo":{"pageNum":1,"pageSize":10,"size":1,"startRow":1,"endRow":1,"total":1,"pages":1,"firstPage":1,"prePage":0,"nextPage":0,"lastPage":1,"isFirstPage":true,"isLastPage":true,"hasPreviousPage":false,"hasNextPage":false,"navigatePages":8,"navigatepageNums":[1]}
@property(nonatomic,assign)NSInteger uid;
@property(nonatomic,assign)NSInteger courseId;

@property(nonatomic,assign)NSInteger type;

@property(nonatomic,assign)NSInteger classId;

@property(nonatomic,copy)NSString*createdAt;


@property(nonatomic,copy)NSString* name;
@property(nonatomic,copy)NSString*className;
@property(nonatomic,copy)NSString*courseName;

@property(nonatomic,copy)NSString*myDescription;


@end
