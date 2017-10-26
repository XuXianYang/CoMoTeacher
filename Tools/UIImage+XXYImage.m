#import "UIImage+XXYImage.h"

@implementation UIImage (XXYImage)

+ (instancetype)imageWithOriginalNamed:(NSString *)imageName
{
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


@end
