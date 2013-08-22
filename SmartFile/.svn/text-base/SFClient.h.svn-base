#import <Foundation/Foundation.h>
#import "AFNetworking.h"

extern NSString *const SFApiUrl;
extern NSString *const SFApiVersion;
extern NSString *const SFHttpUserAgent;

typedef void (^SFResponseCallback) (NSData *data, NSInteger statusCode, NSError *error);
typedef void (^SFAuthorizeCallback) (NSError *error);

@interface SFClient : NSObject {
    NSString *_url;
    NSString *_version;
    AFHTTPClient *_httpClient;
}
/**
 *	Use this property to set or get your API url
 */
@property (strong, nonatomic) NSString *url;

/**
 *	Use this property to set or get API version 
 */
@property (strong, nonatomic) NSString *version;

/**
 *  Use this property to set custom HTTP headers.
 */
@property (strong, nonatomic) NSMutableDictionary *defaultHeaders;

/**
 *	Used to initialize a new object
 *
 *	@return	An initialized object.
 */
- (id)init;

/**
 *	Used to initialize a new object
 *
 *	@param	url Your API url
 *	@param	version	API version
 *
 *	@return	An initialized object.
 */
- (id)initWithUrl:(NSString *)url version:(NSString *)version;

/**
 *	Executes PUT request to the endpoint and object with query params
 *
 *	@param	endpoint The endpoint the request sent to
 *	@param	object Object name or object path
 *	@param	query Key-Value pairs of request params
 *	@param	callback A block object to be executed when request is finished
 *
 *	@return	nil if request is enqueued successfully or NSError object with error code and description
 */
- (NSError *)doPutRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback;

/**
 *	Executes DELETE request to the endpoint and object with query params
 *
 *	@param	endpoint The endpoint the request sent to
 *	@param	object Object name or object path
 *	@param	query Key-Value pairs of request params
 *	@param	callback A block object to be executed when request is finished
 *
 *	@return	nil if request is enqueued successfully or NSError object with error code and description
 */
- (NSError *)doDeleteRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback;

/**
 *	Executes GET request to the endpoint and object with query params
 *
 *	@param	endpoint The endpoint the request sent to
 *	@param	object Object name or object path
 *	@param	query Key-Value pairs of request params
 *	@param	callback A block object to be executed when request is finished
 *
 *	@return	nil if request is enqueued successfully or NSError object with error code and description
 */
- (NSError *)doGetRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback;

/**
 *	Executes GET request to the endpoint and object with query params and output file path
 *
 *	@param	endpoint The endpoint the request sent to
 *	@param	object Object name or object path
 *	@param	query Key-Value pairs of request params
 *  @param  filePath The output file path that is used to write data received until the request is finished. 
 *	@param	callback A block object to be executed when request is finished
 *
 *	@return	nil if request is enqueued successfully or NSError object with error code and description
 */
- (NSError *)doGetRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query outputFile:(NSString *)filePath callback:(SFResponseCallback)callback;

/**
 *	Executes POST request to the endpoint and object with query params
 *
 *	@param	endpoint The endpoint the request sent to
 *	@param	object Object name or object path
 *	@param	query Key-Value pairs of request params
 *	@param	callback A block object to be executed when request is finished
 *
 *	@return	nil if request is enqueued successfully or NSError object with error code and description
 */
- (NSError *)doPostRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query callback:(SFResponseCallback)callback;

/**
 *	Executes POST request to the endpoint and object with query params and array of file paths in local filesystem.
 *
 *	@param	endpoint The endpoint the request sent to
 *	@param	object Object name or object path
 *	@param	query Key-Value pairs of request params
 *  @param  files Array of file paths in local filesystem which must be uploaded
 *	@param	callback A block object to be executed when request is finished
 *
 *	@return	nil if request is enqueued successfully or NSError object with error code and description
 */
- (NSError *)doPostRequest:(NSString *)endpoint object:(NSString *)object query:(NSDictionary *)query files:(NSArray *)files callback:(SFResponseCallback)callback;

/**
 *  Sets the value for the HTTP headers set in request objects made by the HTTP client. If `nil`, removes the existing
 *  value for that header.
 *
 *  @param header The HTTP header to set a default value for
 *  @param value The value set as default for the specified header, or `nil
 */
- (void)setDefaultHeader:(NSString *)header value:(NSString *)value;

@end
