#import "XXYCourseWareListModel.h"

@implementation XXYCourseWareListModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"uid",@"description":@"myDescription"}];
}

@end
