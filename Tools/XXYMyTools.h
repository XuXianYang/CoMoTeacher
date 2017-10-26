#import <Foundation/Foundation.h>

@interface XXYMyTools : NSObject

//判断字符串是否包含空格
+(BOOL)isEmpty:(NSString *) str;
//判断字符串是否有中文
+(BOOL)isChinese:(NSString *)str;
//判断是否是电话号码
+ (NSString *)valiMobile:(NSString *)mobile;
//判断照相机是否授权
+(BOOL)isCameraValid;
//处理拍照的图片翻转
+ (UIImage *)fixOrientation:(UIImage *)aImage;

+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

//判断是否是iponeX
+(BOOL)isIphoneX;
//返回tabbabr高度
+(CGFloat)tabbarHeight;
//返回状态栏高度
+(CGFloat)statesBarHeight;
//减去导航栏和状态栏的高度
+(CGFloat)normalTableheight;
@end
