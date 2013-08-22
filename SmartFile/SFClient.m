#import "SFClient.h"
#import "SFErrors.h"

NSString *const SFApiUrl = @"https://app.smartfile.com/";
NSString *const SFApiVersion = @"2";
NSString *const SFHttpUserAgent = @"SmartFile Obj-C API client v1";

@implementation SFClient
@synthesize url = _url;
@synthesize version = _version;
@synthesize defaultHeaders = _defaultHeaders;

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if(self) {
        _url = SFApiUrl;
        _version = SFApiVersion;
        self.defaultHeaders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithUrl:(NSString *)url version:(NSString *)version {
    self = [super init];
    if(self) {
        _url = ([url length]) ? (url) : (SFApiUrl);
        _version = ([version length]) ? (version) : (SFApiVersion);
        self.defaultHeaders = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Properties

- (void)setUrl:(NSString *)url {
    _url = ([url length]) ? (url) : (SFApiUrl);
}

- (void)setVersion:(NSString *)version {
    _version = ([version length]) ? (version) : (SFApiVersion);
}

#pragma mark - Requests

- (NSError *)doPutRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback {
    return [self doRequest:@"PUT" endpoint:endpoint object:object query:query files:nil outputFile:nil callback:callback];
}

- (NSError *)doDeleteRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback {
    return [self doRequest:@"DELETE" endpoint:endpoint object:object query:query files:nil outputFile:nil callback:callback];
}

- (NSError *)doGetRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback {
    return [self doRequest:@"GET" endpoint:endpoint object:object query:query files:nil outputFile:nil callback:callback];
}

- (NSError *)doGetRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query outputFile:(NSString *)filePath callback:(SFResponseCallback)callback {
    return [self doRequest:@"GET" endpoint:endpoint object:object query:query files:nil outputFile:filePath callback:callback];
}

- (NSError *)doPostRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback {
    return [self doRequest:@"POST" endpoint:endpoint object:object query:query files:nil outputFile:nil callback:callback];
}

- (NSError *)doPostRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query files:(NSArray *)files callback:(SFResponseCallback)callback {
    return [self doRequest:@"POST" endpoint:endpoint object:object query:query files:files outputFile:nil callback:callback];
}

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value
{
    [self.defaultHeaders setValue:value forKey:header];
}

#pragma mark - Internal

- (AFHTTPClient *)httpClient:(NSError *__autoreleasing *)error {
    if(error) *error = errorWithCode(SFErrorCode_Internal);
    return nil;
}

- (NSError *)doRequest:(NSString *)method endpoint:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query files:(NSArray *)files outputFile:(NSString *)filePath callback:(SFResponseCallback)callback {
    NSError *error = nil;
    
    NSString *path = [NSString stringWithFormat:@"/api/%@/", _version];
    path = [path stringByAppendingPathComponent:endpoint];
    
    if([object length]) path = [path stringByAppendingPathComponent:object];
    path = [path stringByAppendingString:@"/"];
    
    AFHTTPClient *httpClient = [self httpClient:&error];
    if(!httpClient) return error;
    
    // Set default headers.
    [_defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [httpClient setDefaultHeader:key value:obj];
    }];
    
    NSMutableURLRequest *request = nil;
    if([method isEqualToString:@"POST"] && [files count]) {
        request = [httpClient multipartFormRequestWithMethod:method path:path parameters:query constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for(NSString *filePath in files) {
                NSError *error = nil;
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                
                BOOL success = [formData appendPartWithFileURL:fileURL name:[fileURL lastPathComponent] error:&error];
                if(!success) NSLog(@"Can't transfer file '%@'. Error: %@", filePath, error);
            }
        }];
    }
    else {
        request = [httpClient requestWithMethod:method path:path parameters:query];
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    if([filePath length]) [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(responseObject, operation.response.statusCode, nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(nil, operation.response.statusCode, error);
    }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
    return error;
}

@end
