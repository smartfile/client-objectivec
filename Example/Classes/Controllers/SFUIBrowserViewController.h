#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SFUIBrowserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSMutableArray *_remoteStructure;
    
    UITableView *_tableView;
    UIToolbar *_toolBar;
    
    NSString *_remotePath;
    BOOL _firstShow;
}

@end
