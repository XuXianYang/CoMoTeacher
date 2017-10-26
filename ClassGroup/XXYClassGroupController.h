#import <UIKit/UIKit.h>
#import "RongIMKit/RongIMKit.h"

@protocol XXYSendClearMessageInfoDelegate <NSObject>

-(void)clearMessage;



@end

@interface XXYClassGroupController:UIViewController

@property(nonatomic,copy)NSString*targetId;

@property(nonatomic,weak)id<XXYSendClearMessageInfoDelegate>sendDelegate;

@end

