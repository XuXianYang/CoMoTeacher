#import "XXYProfileSettingCell.h"

@interface XXYProfileSettingCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end
@implementation XXYProfileSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)layoutSubviews
{
    switch (self.index) {
        case 0:
        {
            _iconImageView.image=[UIImage imageNamed:@"mFpassword"];
            _titleLabel.text=@"修改密码";
        }
            break;
        case 1:
        {
            _iconImageView.image=[UIImage imageNamed:@"personInfo"];
            _titleLabel.text=@"修改资料";

        }
            break;

        case 2:
        {
            _iconImageView.image=[UIImage imageNamed:@"aboutus"];
            _titleLabel.text=@"关于我们";

        }
            break;

            
        default:
            break;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
