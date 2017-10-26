//
//  XXYClassListController.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/9.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXYPublishContentTypeListDelegate <NSObject>

-(void)sendPublishTypeName:(NSString*)title andIndex:(NSInteger)index andtypeId:(NSNumber*)typeId;

@end

@protocol XXYSendClassDictDelegate <NSObject>

-(void)sendClassInfoDict:(NSDictionary*)dict andIndex:(NSInteger)index;

@end

@interface XXYClassListController : UIViewController

@property(nonatomic,strong)NSString*titleName;

@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)NSNumber * classOfId;


@property(nonatomic,weak)id<XXYPublishContentTypeListDelegate>publishDelegate;

@property(nonatomic,weak)id<XXYSendClassDictDelegate>sendClassInfoDictDelegate;

@end
