
#import "OAuthClientTests.h"

#import "Credentials.h"

@implementation OAuthClientTests

- (void)setUp
{
    [super setUp];
    self.oauthClient = [[SFOAuth1Client alloc] initWithUrl:SM_API_URL version:SM_API_VERSION];
}

- (void)tearDown
{
    self.oauthClient = nil;
    [super tearDown];
}

- (void)testAuthorization
{
    // See SmartFileExample SFUIAuthViewController.m
}

@end
