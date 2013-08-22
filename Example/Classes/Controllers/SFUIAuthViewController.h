#import <UIKit/UIKit.h>

@interface SFUIAuthViewController : UIViewController {
    UIToolbar *_toolBar;
    UIButton *_loginButton;
    
    UILabel *_keyLabel;
    UITextField *_keyTextField;
    
    UILabel *_passLabel;
    UITextField *_passTextField;
}
@property (readonly, nonatomic) UITextField *keyTextField;
@property (readonly, nonatomic) UITextField *passTextField;

@end
