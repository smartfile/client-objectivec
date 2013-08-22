#import "NSObject+AssociatedObjectCategory.h"
#import "SFUIBrowserViewController.h"
#import "SFRemoteObject.h"
#import "SFAppDelegate.h"
#import "SFClient.h"

#define SF_ARCHIVE_ACTIONS_TAG 0x1001
#define SF_FILE_DOWNLOAD_TAG   0x1002
#define SF_FILE_UPLOAD_TAG     0x1003

#define CELL_HEIGHT 50

static inline void showIndicatorAndBlockUI(void) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

static inline void hideIndicatorAndUnblockUI(void) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

@implementation SFUIBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    _remoteStructure = [NSMutableArray array];
    _remotePath = @"/";
    _firstShow = YES;
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _toolBar.barStyle = UIBarStyleBlackOpaque;
    [self.view addSubview:_toolBar];
    [self setToolBarItems:NO withUploadButton:NO];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_toolBar.frame), self.view.bounds.size.width, self.view.bounds.size.height - _toolBar.bounds.size.height) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.bounces = NO;
    [self.view addSubview:_tableView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_firstShow) {
        _firstShow = NO;
        [self openDir:nil];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([_remoteStructure count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellID = @"kCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"CellBackground.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.opaque = YES;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width - 30, (CELL_HEIGHT - 20)/2, 20, 20)];
        [button addTarget:self action:@selector(deleteBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitle:@"×" forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 1, 2, 0)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:17]];
        [[button layer] setCornerRadius:button.bounds.size.width / 2];
        [[button layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[button layer] setBorderWidth:2.0f];
        [cell addSubview:button];
    }
    
    SFRemoteObject *remoteObject = [_remoteStructure objectAtIndex:indexPath.row];
    if(remoteObject.isDir && !remoteObject.isFile) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.text = [NSString stringWithFormat:@"[%@]", remoteObject.name];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.text = remoteObject.name;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SFRemoteObject *remoteObject = [_remoteStructure objectAtIndex:indexPath.row];
    [self performActionOnObject:remoteObject];
}

#pragma mark - Toolbar button actions

- (void)backButtonPressed:(UIBarButtonItem *)item {
    _remotePath = [_remotePath stringByDeletingLastPathComponent];
    [self openDir:nil];
}

- (void)uploadButtonPressed:(UIBarButtonItem *)item {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Upload Archive.zip", @"Upload Image.png", @"Upload Text.txt", @"Upload all files", @"Create directory", nil];
    alertView.tag = SF_FILE_UPLOAD_TAG;
    [alertView show];
}

- (void)deleteBtnPressed:(UIButton *)button {
    UITableViewCell *cell = (UITableViewCell *)button.superview;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    SFRemoteObject *remoteObject = [_remoteStructure objectAtIndex:indexPath.row];
    [self deleteObject:remoteObject];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    SFRemoteObject *remoteObject = (SFRemoteObject *)alertView.associatedObject;
    NSLog(@"object name = %@", remoteObject.name);
    
    switch (alertView.tag) {
        case SF_ARCHIVE_ACTIONS_TAG: {
            if(buttonIndex == 1) {
                [self openDir:remoteObject.name];
            }
            else if(buttonIndex == 2) {
                [self showDownloadAlertForObject:remoteObject];
            }
        }
        break;

        case SF_FILE_DOWNLOAD_TAG:{
            if(buttonIndex == 1) {
                [self downloadObject:remoteObject];
            }
        }
        break;

        case SF_FILE_UPLOAD_TAG: {
            
            NSMutableArray *files = [NSMutableArray array];
            if(buttonIndex == 1) {
                [files addObject:[[NSBundle mainBundle] pathForResource:@"Archive" ofType:@"zip"]];
            }
            else if(buttonIndex == 2) {
                [files addObject:[[NSBundle mainBundle] pathForResource:@"Image" ofType:@"png"]];
            }
            else if(buttonIndex == 3) {
                [files addObject:[[NSBundle mainBundle] pathForResource:@"Text" ofType:@"txt"]];
            }
            else if(buttonIndex == 4) {
                [files addObject:[[NSBundle mainBundle] pathForResource:@"Archive" ofType:@"zip"]];
                [files addObject:[[NSBundle mainBundle] pathForResource:@"Image" ofType:@"png"]];
                [files addObject:[[NSBundle mainBundle] pathForResource:@"Text" ofType:@"txt"]];
            }
            else {
                [self createDir];
                return;
            }
            
            [self uploadFiles:files];
        }
        break;
            
        default:
            break;
    }
}

#pragma mark - Useful methods

- (void)openDir:(NSString *)dir {   
    SFClient *client = [SFAppDelegate sharedDelegate].client;
    
    NSMutableString *object = [_remotePath mutableCopy];
    if([dir length]) [object appendFormat:@"/%@", dir];
        
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setValue:@"true" forKey:@"children"];
    
    void (^errorBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SmartFileApi" message:[NSString stringWithFormat:@"Can't load '%@' path", object] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    };
    
    showIndicatorAndBlockUI();
    NSError *error = [client doGetRequest:@"/path/info/" object:object query:query callback:^(NSData *data, NSInteger statusCode, NSError *error) {
        hideIndicatorAndUnblockUI();
        if(error != nil) {
            errorBlock();
        }
        else {
            NSDictionary *jsonDict = (data) ? ([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]) : (nil);            
            NSArray *childrens = [jsonDict valueForKey:@"children"];
            
            //Get all objects
            [_remoteStructure removeAllObjects];
            for(NSDictionary *dictionary in childrens) {
                SFRemoteObject *remoteObject = [[SFRemoteObject alloc] initWithDictionary:dictionary];
                [_remoteStructure addObject:remoteObject];
            }
            
            //Sort objects (By type (folders is on top) and by name (alpabetically)
            [_remoteStructure sortUsingComparator:^NSComparisonResult(SFRemoteObject *object1, SFRemoteObject *object2) {
                if((object1.isDir == object2.isDir) || (object1.isFile && object2.isFile)) {
                    return ([object1.name compare:object2.name]);
                }
                else {
                    return (object1.isDir && object2.isFile) ? (NSOrderedAscending) : (NSOrderedDescending);
                }
            }];
            
            //Save path
            _remotePath = [jsonDict valueForKey:@"path"];
            
            BOOL canGoBack = ([_remotePath length] && ![_remotePath isEqualToString:@"/"]);
            BOOL canUpload = YES;
                        
            //Set new toolbar items
            [self setToolBarItems:canGoBack withUploadButton:canUpload];
            
            //Reload table view with animation
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    if(error != nil) {
        hideIndicatorAndUnblockUI();
        errorBlock();
    }
}

- (void)createDir {
    
    static NSDateFormatter *dateFormatter = nil;
    if(dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ddMMyyyy__HHmmss"];
    }
    
    NSDate *date = [NSDate date];
    NSString *dirName = [dateFormatter stringFromDate:date];
        
    void (^errorBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SmartFileApi" message:[NSString stringWithFormat:@"Can't create '%@' directory", dirName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    };
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setValue:[_remotePath stringByAppendingPathComponent:dirName] forKey:@"path"];
    
    showIndicatorAndBlockUI();
    SFClient *client = [SFAppDelegate sharedDelegate].client;
    NSError *error = [client doPostRequest:@"/path/oper/mkdir/" object:nil query:query callback:^(NSData *data, NSInteger statusCode, NSError *error) {
        hideIndicatorAndUnblockUI();
        if(error != nil) {
            errorBlock();
        }
        else {
            [self openDir:nil];
        }
    }];
    
    if(error != nil) {
        hideIndicatorAndUnblockUI();
        errorBlock();
    }
}

- (void)deleteObject:(SFRemoteObject *)remoteObject {
    SFClient *client = [SFAppDelegate sharedDelegate].client;
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setValue:remoteObject.path forKey:@"path"];
    
    void (^errorBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SmartFileApi" message:[NSString stringWithFormat:@"Can't remove '%@' file", remoteObject.path] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    };
    
    showIndicatorAndBlockUI();
    NSError *error = [client doPostRequest:@"/path/oper/remove/" object:nil query:query callback:^(NSData *data, NSInteger statusCode, NSError *error) {
        hideIndicatorAndUnblockUI();
        if(error != nil) {
            errorBlock();
        }
        else {           
            [_remoteStructure removeObject:remoteObject];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    if(error != nil) {
        hideIndicatorAndUnblockUI();
        errorBlock();
    }
}

- (void)downloadObject:(SFRemoteObject *)remoteObject {
    SFClient *client = [SFAppDelegate sharedDelegate].client;
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *outputFilePath = [documentsDir stringByAppendingPathComponent:remoteObject.name];
    
    void (^errorBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SmartFileApi" message:[NSString stringWithFormat:@"Can't download '%@' file", remoteObject.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    };
    
    showIndicatorAndBlockUI();
    NSError *error = [client doGetRequest:@"/path/data/" object:remoteObject.path query:nil outputFile:outputFilePath callback:^(NSData *data, NSInteger statusCode, NSError *error) {
        hideIndicatorAndUnblockUI();
        if(error != nil) {
            errorBlock();
        }
        else {
            
            NSFileManager *fileManger = [NSFileManager defaultManager];
            NSDictionary *attributes = [fileManger attributesOfItemAtPath:outputFilePath error:nil];
            
            uint64_t downloadedFileSize = [[attributes valueForKey:NSFileSize] unsignedLongLongValue];
            if(downloadedFileSize == remoteObject.size) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SmartFileApi" message:@"File has been downloaded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SmartFileApi" message:@"Download Error\nSomething happened during the download file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
    
    if(error != nil) {
        hideIndicatorAndUnblockUI();
        errorBlock();
    }

}

- (void)uploadFiles:(NSArray *)files {
    void (^errorBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SmartFileApi" message:@"Can't upload" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    };
    
    showIndicatorAndBlockUI();
    SFClient *client = [SFAppDelegate sharedDelegate].client;
    NSError *error = [client doPostRequest:@"/path/data/" object:_remotePath query:nil files:files callback:^(NSData *data, NSInteger statusCode, NSError *error) {
        hideIndicatorAndUnblockUI();
        if(error != nil) {
            errorBlock();
        }
        else {
            [self openDir:nil];
        }
    }];
    
    if(error != nil) {
        hideIndicatorAndUnblockUI();
        errorBlock();
    }
}

- (void)setToolBarItems:(BOOL)backButton withUploadButton:(BOOL)uploadButton {
    NSMutableArray *items = [NSMutableArray array];
    
    if(backButton) {
        [items addObject:[[UIBarButtonItem alloc] initWithTitle:@" < " style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed:)]];
    }
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL]];
    
    if(uploadButton) {
        [items addObject:[[UIBarButtonItem alloc] initWithTitle:@" + " style:UIBarButtonItemStyleBordered target:self action:@selector(uploadButtonPressed:)]];
    }
    
    [_toolBar setItems:items animated:NO];
}

- (void)performActionOnObject:(SFRemoteObject *)object {
    UIAlertView *alertView = nil;
    
    if(object.isDir && object.isFile) {
        alertView = [[UIAlertView alloc] initWithTitle:@"What you gonna do with this archive?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open", @"Download", nil];
        alertView.tag = SF_ARCHIVE_ACTIONS_TAG;
    }
    else if(object.isFile) {
        [self showDownloadAlertForObject:object];
    }
    else if(object.isDir) {
        [self openDir:object.name];
    }
    
    [alertView setAssociatedObject:object];
    [alertView show];
}

- (void)showDownloadAlertForObject:(SFRemoteObject *)object {
    UIAlertView *alertView = nil;
    
    alertView = [[UIAlertView alloc] initWithTitle:@"Download file" message:[NSString stringWithFormat:@"%@\n%lld bytes", object.name, object.size] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Download", nil];
    alertView.tag = SF_FILE_DOWNLOAD_TAG;
    
    [alertView setAssociatedObject:object];
    [alertView show];
    
}

@end
