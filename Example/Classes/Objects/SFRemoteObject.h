#import <Foundation/Foundation.h>

@interface SFRemoteObject : NSObject

@property (assign, nonatomic) BOOL isDir;
@property (assign, nonatomic) BOOL isFile;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) uint64_t size;
@property (strong, nonatomic) NSDate *time;

- (id)init;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
