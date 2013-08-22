#import "SFOAuth1Client.h"
#import "AFOAuth1Client.h"
#import "SFErrors.h"
#import "SFUtils.h"

@implementation SFOAuth1Client
@dynamic accessToken;
@dynamic accessSecret;
@dynamic clientToken;
@dynamic clientSecret;

- (NSError *)authorizeWithToken:(NSString *)token secret:(NSString *)secret callback:(SFAuthorizeCallback)callback {
    
    NSString *validToken = [SFUtils checkAuthValue:token];
    if(!validToken) return errorWithCode(SFErrorCode_InvalidArgument);

    NSString *validSecret = [SFUtils checkAuthValue:secret];
    if(!validSecret) return errorWithCode(SFErrorCode_InvalidArgument);
    
    AFOAuth1Client *oauthClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:_url] key:token secret:secret];
    if(!oauthClient) return errorWithCode(SFErrorCode_Internal);
    
    [oauthClient setDefaultHeader:@"User-Agent" value:SFHttpUserAgent];
    [oauthClient authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token/"
                                   userAuthorizationPath:@"/oauth/authorize/"
                                             callbackURL:[NSURL URLWithString:_url]
                                         accessTokenPath:@"/oauth/access_token/"
                                            accessMethod:@"POST"
                                                   scope:nil
                                                 success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                     _httpClient = oauthClient;
                                                     callback(nil);
                                                 }
                                                 failure:^(NSError *error) {
                                                     callback(error);
                                                 }];
    
    return nil;
}

- (NSString *)accessToken {
    AFOAuth1Client *oauthClient = (AFOAuth1Client *)[self httpClient:nil];
    return (oauthClient) ? (oauthClient.accessToken.key) : (nil);
}

- (NSString *)accessSecret {
    AFOAuth1Client *oauthClient = (AFOAuth1Client *)[self httpClient:nil];
    return (oauthClient) ? (oauthClient.accessToken.secret) : (nil);
}

- (NSString *)clientToken {
    AFOAuth1Client *oauthClient = (AFOAuth1Client *)[self httpClient:nil];
    return (oauthClient) ? (oauthClient.accessToken.key) : (nil);
}

- (NSString *)clientSecret {
    AFOAuth1Client *oauthClient = (AFOAuth1Client *)[self httpClient:nil];
    return (oauthClient) ? (oauthClient.accessToken.secret) : (nil);
}

#pragma mark - Internal

- (AFHTTPClient *)httpClient:(NSError *__autoreleasing *)error {
    if(!_httpClient) {
        if(error) {
            *error = errorWithCode(SFErrorCode_AuthRequired);
        }
    }
    return _httpClient;
}

@end
