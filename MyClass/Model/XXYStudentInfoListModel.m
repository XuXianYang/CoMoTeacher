#import "XXYStudentInfoListModel.h"

@implementation XXYStudentInfoListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"uid"}];
}
@end
