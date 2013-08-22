#import "SFUIWebControl.h"
#import "AFOAuth1Client.h"

@implementation SFUIWebControl
@synthesize callbackUrl = _callbackUrl;
@synthesize webView = _webView;

- (id)init {    
    self = [super initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    if(self) {
        
        self.alpha = 0.0f;
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 20)];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.scrollView.bouncesZoom = NO;
        _webView.scrollView.bounces = NO;
        _webView.scalesPageToFit = YES;
        _webView.delegate = self;
        _webView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _webView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        _webView.layer.shadowOpacity = 1.0f;
        _webView.layer.shadowRadius = 4.0f;
        [self addSubview:_webView];
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 25, 5, 20, 20)];
        [_closeBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_closeBtn addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_closeBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_closeBtn setBackgroundColor:[UIColor whiteColor]];
        [_closeBtn setTitle:@"×" forState:UIControlStateNormal];
        [_closeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 1, 2, 0)];
        [_closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [[_closeBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:17]];
        [[_closeBtn layer] setCornerRadius:_closeBtn.bounds.size.width / 2];
        [[_closeBtn layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[_closeBtn layer] setBorderWidth:2.0f];
        [self addSubview:_closeBtn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

#pragma mark - Appearance methods

- (void)show {
    if(self.superview) return;
    else [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

- (void)hide {
    if(!self.superview)
        return;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Close button action

- (void)closeButtonPressed:(UIButton *)button {
    [_webView stopLoading];
    [self hide];
    
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    NSRange range = [url rangeOfString:@"oauth_verifier"];
    
    if(range.location == NSNotFound) {
        range = [url rangeOfString:@"verifier"];
    }
    
    if(range.location == NSNotFound) {
        return YES;
    }
    
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[request URL] forKey:kAFApplicationLaunchOptionsURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self hide];
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Notifications

- (void)statusBarOrientationChanged:(NSNotification *)notification {
    CGFloat angle = 0.0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            angle = - M_PI_2;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
            
        default:
            angle = 0.0;
            break;
    }
    
    self.transform = CGAffineTransformMakeRotation(angle);
    self.frame = [[UIScreen mainScreen] applicationFrame];
}

@end
