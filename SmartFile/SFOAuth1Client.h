#import "SFClient.h"

@interface SFOAuth1Client : SFClient

/**
 *	Use this property to retrieve access token
 */
@property (readonly, nonatomic) NSString *accessToken;

/**
 *	Use this property to retrieve access secret
 */
@property (readonly, nonatomic) NSString *accessSecret;

/**
 *	Use this property to retrieve your client token
 */
@property (readonly, nonatomic) NSString *clientToken;

/**
 *	Use this property to retrieve your client secret
 */
@property (readonly, nonatomic) NSString *clientSecret;

/**
 *	Starts OAuth1 authentication with client token and client secret
 *
 *	@param	token Your client token
 *	@param	secret Your clien secret
 *	@param	callback A block object to be executed when authentication is finished
 *
 *	@return	nil if authentication request is enqueued successfully or NSError object with error code and description
 */
- (NSError *)authorizeWithToken:(NSString *)token secret:(NSString *)secret callback:(SFAuthorizeCallback)callback;

@end
