#import "SFAppDelegate.h"
#import "SFBasicClient.h"
#import "SFOAuth1Client.h"
#import "SFUIAuthViewController.h"
#import "SFUIBrowserViewController.h"

@implementation SFUIAuthViewController
@synthesize keyTextField = _keyTextField;
@synthesize passTextField = _passTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _toolBar.barStyle = UIBarStyleBlackOpaque;
    [self.view addSubview:_toolBar];
    
    UISegmentedControl *sControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@" Basic ", @" OAuth ", nil]];
    [sControl addTarget:self action:@selector(onAuthTypeChanged:) forControlEvents:UIControlEventValueChanged];
    sControl.segmentedControlStyle = UISegmentedControlStyleBar;
    sControl.selectedSegmentIndex = 0;
    sControl.momentary = NO;
    
    UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:sControl];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    [_toolBar setItems:[NSArray arrayWithObjects:spaceItem, segmentItem, spaceItem, nil] animated:NO];
    
    _keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_toolBar.frame) + 20, self.view.bounds.size.width - 40, 20)];
    _keyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _keyLabel.backgroundColor = [UIColor clearColor];
    _keyLabel.textAlignment = UITextAlignmentLeft;
    _keyLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_keyLabel];
    
    _keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_keyLabel.frame), self.view.bounds.size.width - 40, 40)];
    _keyTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _keyTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _keyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _keyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _keyTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_keyTextField];
    
    _passLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_keyTextField.frame) + 20, self.view.bounds.size.width - 40, 20)];
    _passLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passLabel.backgroundColor = [UIColor clearColor];
    _passLabel.textAlignment = UITextAlignmentLeft;
    _passLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_passLabel];
    
    _passTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_passLabel.frame), self.view.bounds.size.width - 40, 40)];
    _passTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_passTextField];
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginButton.frame = CGRectMake(20, self.view.bounds.size.height - 60, self.view.bounds.size.width - 40, 40);
    _loginButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [_loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.view addSubview:_loginButton];
    
    [self onAuthTypeChanged:sControl];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)onAuthTypeChanged:(UISegmentedControl *)sControl {
    _toolBar.tag = sControl.selectedSegmentIndex;
    if(sControl.selectedSegmentIndex == 0) {
        _keyTextField.text = SM_BASIC_API_KEY;
        _passTextField.text = SM_BASIC_API_PASSWORD;
        
        _keyLabel.text = @"Your key:";
        _passLabel.text = @"Your password:";
    }
    else {
        _keyTextField.text = SM_OAUTH_TOKEN;
        _passTextField.text = SM_OAUTH_SECRET;
        
        _keyLabel.text = @"Your token:";
        _passLabel.text = @"Your secret:";
    }
}

- (void)loginButtonPressed:(UIButton *)button {
    if(_toolBar.tag == 0) {
        //Basic
        NSError *error = nil;
        SFBasicClient *basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];
        
        error = [basicClient setKey:_keyTextField.text];
        if(error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Key is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        error = [basicClient setPassword:_passTextField.text];
        if(error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        //Use 'ping' endpoint to check credentials
        error = [basicClient doGetRequest:@"/ping" object:nil query:nil callback:^(NSData *data, NSInteger statusCode, NSError *error) {
            if(error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't login. Check your key/password and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else {
                [SFAppDelegate sharedDelegate].client = basicClient;
                SFUIBrowserViewController *browserVC = [[SFUIBrowserViewController alloc] init];
                [self.navigationController pushViewController:browserVC animated:YES];
            }
        }];
        
        if(error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Key or password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    else {
        //OAuth
        NSError *error = nil;
        SFOAuth1Client *oauthClient = [[SFOAuth1Client alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];
        
        //Authorize with token and secret
        error = [oauthClient authorizeWithToken:_keyTextField.text secret:_passTextField.text callback:^(NSError *error) {
            if(error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't login. Check your token/secret and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else {
                [SFAppDelegate sharedDelegate].client = oauthClient;
                SFUIBrowserViewController *browserVC = [[SFUIBrowserViewController alloc] init];
                [self.navigationController pushViewController:browserVC animated:YES];
            }
        }];
        
        if(error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token or secret is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_keyTextField resignFirstResponder];
    [_passTextField resignFirstResponder];
}

@end
