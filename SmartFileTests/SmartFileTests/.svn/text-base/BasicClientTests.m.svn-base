
#import "BasicClientTests.h"

#import "Credentials.h"

#define SF_VERBOSE

typedef NS_ENUM(NSInteger, SFRequestType) {
    SF_GET = 0,
    SF_PUT,
    SF_POST,
    SF_DELETE
};

@implementation BasicClientTests

- (void)setUp
{
    [super setUp];
    self.basicClient = [[SFBasicClient alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];
}

- (void)tearDown
{
    self.basicClient = nil;
    [super tearDown];
}

- (void)setKey:(NSString *)key andPassword:(NSString *)password
{
    [self.basicClient setKey:SM_BASIC_API_KEY];
    [self.basicClient setPassword:SM_BASIC_API_PASSWORD];
}

- (void)testRequestType:(SFRequestType)type
                request:(NSString *)request
                 object:(NSString *)object
                  query:(NSDictionary *)query
                payload:(id)payload
{
    NSError *credError = nil;
    
    __block NSData    *responseData      = nil;
    __block NSInteger responseStatusCode = 0;
    __block NSError   *responseError     = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    SFResponseCallback callback = ^(NSData *data, NSInteger statusCode, NSError *error) {
        responseData       = data;
        responseStatusCode = statusCode;
        responseError      = error;
        dispatch_semaphore_signal(semaphore);
    };
    
    switch (type) {
        case SF_GET: {
            if (payload == nil) {
                credError = [self.basicClient doGetRequest:request object:object query:query callback:callback];
            } else {
                credError = [self.basicClient doGetRequest:request
                                                    object:object
                                                     query:query
                                                outputFile:(NSString *)payload
                                                  callback:callback];
            }
            break;
        }
        case SF_PUT:
            credError = [self.basicClient doPutRequest:request object:object query:query callback:callback];
            break;
        case SF_POST: {
            if (payload == nil) {
                credError = [self.basicClient doPostRequest:request object:object query:query callback:callback];
            } else {
                credError = [self.basicClient doPostRequest:request
                                                     object:object
                                                      query:query
                                                      files:(NSArray *)payload
                                                   callback:callback];
            }
            break;
        }
        case SF_DELETE:
            credError = [self.basicClient doDeleteRequest:request object:object query:query callback:callback];
            break;
        default:
            /* DO NOTHING. */
            break;
    }
    
    // Wait for request to complete.
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    dispatch_release(semaphore);
    
    STAssertNil(credError, @"Key or password is invalid: %@", credError);
    STAssertNil(responseError, @"Response error: %@", responseError);
    
#ifdef SF_VERBOSE
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"\n%d\n%@", responseStatusCode, response);
#endif
}

- (void)testGetRequest:(NSString *)request object:(NSString *)object query:(NSDictionary *)query
{
    [self testRequestType:SF_GET request:request object:object query:query payload:nil];
}

- (void)testGetRequest:(NSString *)request
                object:(NSString *)object
                 query:(NSDictionary *)query
            outputFile:(NSString *)filePath
{
    [self testRequestType:SF_GET request:request object:object query:query payload:filePath];
}

- (void)testPutRequest:(NSString *)request object:(NSString *)object query:(NSDictionary *)query
{
    [self testRequestType:SF_PUT request:request object:object query:query payload:nil];
}

- (void)testPostRequest:(NSString *)request object:(NSString *)object query:(NSDictionary *)query
{
    [self testRequestType:SF_POST request:request object:object query:query payload:nil];
}

- (void)testDeleteRequest:(NSString *)request object:(NSString *)object query:(NSDictionary *)query
{
    [self testRequestType:SF_DELETE request:request object:object query:query payload:nil];
}

- (void)testPostRequest:(NSString *)request
                 object:(NSString *)object
                  query:(NSDictionary *)query
                  files:(NSArray *)files
{
    [self testRequestType:SF_POST request:request object:object query:query payload:files];
}

- (void)test_00_Credentials
{
    NSError *error = nil;
    error = [self.basicClient setKey:SM_BASIC_API_KEY];
    STAssertNil(error, @"Key is invalid: @", error);
    error = [self.basicClient setPassword:SM_BASIC_API_PASSWORD];
    STAssertNil(error, @"Password is invalid: %@", error);
}

- (void)test_01_Ping
{
    [self testGetRequest:@"/ping" object:nil query:nil];
}

- (void)test_02_PathInfo
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/path/info" object:nil query:nil];
}

- (void)test_03_fileUpload
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
}

- (void)test_04_fileDownload
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Download file.
    NSString *outPath = [@"~/test_file.txt" stringByExpandingTildeInPath];
    [self testGetRequest:@"/path/data" object:@"/test_file.txt" query:nil outputFile:outPath];
    // Compare with original.
    NSString *origFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    NSString *origFile = [NSString stringWithContentsOfFile:origFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *downloadedFile = [NSString stringWithContentsOfFile:outPath encoding:NSUTF8StringEncoding error:nil];
    STAssertEqualObjects(origFile, downloadedFile, @"Downloaded file differs!");
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
}

- (void)test_05_Progress
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self.basicClient setDefaultHeader:@"X-Upload-UUID" value:@"9f1466d1-dc3b-4e86-a625-f4b2ce1c1a10"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    [self testGetRequest:@"/path/progress" object:@"/9f1466d1-dc3b-4e86-a625-f4b2ce1c1a10" query:nil];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
    [self.basicClient setDefaultHeader:@"X-Upload-UUID" value:nil];
}

- (void)test_06_AccessPath
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Access path.
    [self testGetRequest:@"/access/path" object:@"/test_file.txt" query:nil];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
}

- (void)test_07_Search
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Search.
    [self testGetRequest:@"/search/path" object:nil query:@{@"keywords" : @"test_file.txt"}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
}

- (void)test_08_WatchPath
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Watch path.
    [self testPostRequest:@"/watch/paths" object:nil query:@{@"path" : @"/"}];
    // List all the paths currently being watched.
    [self testGetRequest:@"/watch/paths" object:nil query:nil];
    // Delete a watch.
    [self testDeleteRequest:@"/watch/path/" object:nil query:nil];
}

- (void)test_09_Mkdir
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create directory.
    [self testPostRequest:@"/path/oper/mkdir" object:nil query:@{@"path" : @"/test_dir"}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_dir"}];
}

- (void)test_10_Move
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Create directory.
    [self testPostRequest:@"/path/oper/mkdir" object:nil query:@{@"path" : @"/test_dir"}];
    // Move file.
    [self testPostRequest:@"/path/oper/move" object:nil query:@{@"src" : @"/test_file.txt",
                                                                      @"dst" : @"/test_dir"}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_dir"}];
}

- (void)test_11_Rename
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create directory.
    [self testPostRequest:@"/path/oper/mkdir" object:nil query:@{@"path" : @"/test_dir1"}];
    // Rename directory.
    [self testPostRequest:@"/path/oper/rename" object:nil query:@{@"src" : @"/test_dir1",
                                                                        @"dst" : @"/test_dir2"}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_dir2"}];
}

- (void)test_12_Copy
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Create directory.
    [self testPostRequest:@"/path/oper/mkdir" object:nil query:@{@"path" : @"/test_dir"}];
    // Copy file.
    [self testPostRequest:@"/path/oper/copy" object:nil query:@{@"src" : @"/test_file.txt",
                                                                      @"dst" : @"/test_dir/"}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_dir"}];
}

- (void)test_13_Remove
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create directory.
    [self testPostRequest:@"/path/oper/mkdir" object:nil query:@{@"path" : @"/test_dir"}];
    // Remove directory.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_dir"}];
}

- (void)test_14_CheckSum
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Calculate md5.
    [self testPostRequest:@"/path/oper/checksum" object:nil query:@{@"path"      : @"/test_file.txt",
                                                                          @"algorithm" : @"md5"}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
}

- (void)test_15_Compress
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Upload file.
    NSString *testFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file" ofType:@"txt"];
    [self testPostRequest:@"/path/data" object:@"/" query:nil files:@[testFilePath]];
    // Compress file.
    [self testPostRequest:@"/path/oper/compress" object:nil query:@{@"path" : @"/test_file.txt",
                                                                          @"dst"  : @"/",
                                                                          @"name" : @"test_file.zip"}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.txt"}];
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_file.zip"}];
}

- (void)test_16_User
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create user.
    NSString *username = [NSString stringWithFormat:@"bobafett%d", arc4random()];
    [self testPostRequest:@"/user" object:nil query:@{@"name"     : @"boba",
                                                            @"username" : username,
                                                            @"email"    : @"boba.fett@example.com",
                                                            @"password" : @"Kamino1978",
                                                            @"role"     : @"User"}];
    // Clean-up.
    // TODO: Remove user.
}

- (void)test_17_Role
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/role" object:nil query:nil];
}

- (void)test_18_AccessUser
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create user.
    NSString *username = [NSString stringWithFormat:@"bobafett%d", arc4random()];
    [self testPostRequest:@"/user" object:nil query:@{@"name"     : @"boba",
                                                            @"username" : username,
                                                            @"email"    : @"boba.fett@example.com",
                                                            @"password" : @"Kamino1978",
                                                            @"role"     : @"User"}];
    // Create directory.
    [self testPostRequest:@"/path/oper/mkdir" object:nil query:@{@"path" : @"/test_dir"}];
    // Set access rules.
    [self testPostRequest:@"/access/user" object:nil query:@{@"user"   : username,
                                                                   @"path"   : @"/test_dir",
                                                                   @"read"   : @"true",
                                                                   @"write"  : @"false",
                                                                   @"list"   : @"false",
                                                                   @"remove" : @"false"}];
    // Display access rules.
    [self testGetRequest:@"/access/user" object:nil query:nil];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : @"/test_dir"}];
    // TODO: Remove user.
}

- (void)test_19_SearchUser
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create user.
    NSString *username = [NSString stringWithFormat:@"bobafett%d", arc4random()];
    [self testPostRequest:@"/user" object:nil query:@{@"name"     : @"boba",
                                                            @"username" : username,
                                                            @"email"    : @"boba.fett@example.com",
                                                            @"password" : @"Kamino1978",
                                                            @"role"     : @"User"}];
    // Search user.
    [self testGetRequest:@"/search/user" object:nil query:@{@"keywords" : @"boba"}];
    // Clean-up.
    // TODO: Remove user.
}

- (void)test_20_Watch
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create user.
    NSString *username = [NSString stringWithFormat:@"bobafett%d", arc4random()];
    [self testPostRequest:@"/user" object:nil query:@{@"name"     : @"boba",
                                                            @"username" : username,
                                                            @"email"    : @"boba.fett@example.com",
                                                            @"password" : @"Kamino1978",
                                                            @"role"     : @"User"}];
    // Watch user.
    [self testPostRequest:@"/watch/users" object:nil query:@{@"user" : username}];
    // List of watched users.
    [self testGetRequest:@"/watch/users" object:nil query:nil];
    // Clean-up.
    // TODO: Remove watch.
    // TODO: Remove user.
}

- (void)test_21_Group
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/group" object:nil query:nil];
}

- (void)test_22_GroupAccess
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Create directory.
    NSString *dirname = [NSString stringWithFormat:@"/test_dir%d", arc4random()];
    [self testPostRequest:@"/path/oper/mkdir" object:nil query:@{@"path" : dirname}];
    // Set access rules.
    [self testPostRequest:@"/access/group" object:nil query:@{@"group"  : @"Users",
                                                                    @"path"   : dirname,
                                                                    @"read"   : @"true",
                                                                    @"write"  : @"true",
                                                                    @"list"   : @"true",
                                                                    @"remove" : @"true"}];
    // List access rules.
    [self testGetRequest:@"/access/group" object:nil query:@{@"path" : dirname}];
    // Clean-up.
    [self testPostRequest:@"/path/oper/remove" object:nil query:@{@"path" : dirname}];
    // TODO: Remove group access rule.
}

- (void)test_23_SearchGroup
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/search/group" object:nil query:@{@"keywords" : @"Users"}];
}

- (void)test_24_GroupWatch
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    // Watch group.
    [self testPostRequest:@"/watch/groups" object:nil query:@{@"group" : @"Users"}];
    // List watched groups.
    [self testGetRequest:@"/watch/groups" object:nil query:nil];
    // Clean-up.
    [self testDeleteRequest:@"/watch/group/Users" object:nil query:nil];
}

- (void)test_25_Preferences
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/pref" object:nil query:nil];
}
 
- (void)test_26_UserPreferences
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/pref/user" object:nil query:@{@"name" : @"max-per-page", @"value" : @"10"}];
    [self testGetRequest:@"/pref/user" object:nil query:nil];
}

- (void)test_27_Session
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/session" object:nil query:nil];
}

- (void)test_28_Activity
{
    [self setKey:SM_BASIC_API_KEY andPassword:SM_BASIC_API_PASSWORD];
    [self testGetRequest:@"/activity" object:nil query:nil];
}

@end
