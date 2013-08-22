#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SFUIWebControl : UIView <UIWebViewDelegate> {
    NSString *_callbackUrl;
    UIWebView *_webView;
    UIButton *_closeBtn;
}
@property (strong,   nonatomic) NSString *callbackUrl;
@property (readonly, nonatomic) UIWebView *webView;

- (void)show;
- (void)hide;

@end
