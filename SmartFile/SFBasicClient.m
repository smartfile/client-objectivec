#import "SFBasicClient.h"
#import "AFHTTPClient.h"
#import "SFErrors.h"
#import "SFUtils.h"

@implementation SFBasicClient

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if(self) {
        _key = nil;
        _password = nil;
    }
    return self;
}

#pragma mark - Key and password

- (NSError *)setKey:(NSString *)key {
    _key = [SFUtils checkAuthValue:key];
    return (_key) ? (nil) : (errorWithCode(SFErrorCode_InvalidArgument));
}

- (NSError *)setPassword:(NSString *)password {
    _password = [SFUtils checkAuthValue:password];
    return (_password) ? (nil) : (errorWithCode(SFErrorCode_InvalidArgument));
}

#pragma mark - Internal

- (AFHTTPClient *)httpClient:(NSError *__autoreleasing *)error {
    if(!_httpClient) {
        _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:_url]];
        [_httpClient setDefaultHeader:@"User-Agent" value:SFHttpUserAgent];
    }
    
    [_httpClient setAuthorizationHeaderWithUsername:_key password:_password];
    return _httpClient;
}

@end
