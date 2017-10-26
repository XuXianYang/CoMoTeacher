#import <UIKit/UIKit.h>

@protocol XXYSendClassInfoDelegate <NSObject>

-(void)sendclassInfo:(id)multipleChoiceData andIndex:(NSInteger)index;



@end

@interface XXYInfoOfClassForJoinController : UIViewController

@property(nonatomic,copy)NSString*titleName;
@property(nonatomic,assign)NSInteger index;

@property(nonatomic,weak)id<XXYSendClassInfoDelegate>sendclassInfoDelegate;

@end
