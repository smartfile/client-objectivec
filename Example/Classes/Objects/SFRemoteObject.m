#import "SFRemoteObject.h"

@implementation SFRemoteObject

- (id)init {
    self = [super init];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if(self) {
        [self commonInit];
        
        NSDate *time = nil;
        NSNumber *number = nil;
        NSString *string = nil;
        
        number = [dictionary valueForKey:@"isdir"];
        _isDir = [number boolValue];
        
        number = [dictionary valueForKey:@"isfile"];
        _isFile = [number boolValue];
        
        string = [dictionary valueForKey:@"name"];
        _name = string;
        
        string = [dictionary valueForKey:@"path"];
        _path = string;
        
        number = [dictionary valueForKey:@"size"];
        _size = [number unsignedLongLongValue];
        
        time = [dictionary valueForKey:@"time"];
        _time = time;
    }
    return self;
}

- (void)commonInit {
    _isDir = NO;
    _isFile = NO;
    _name = @"";
    _path = @"";
    _size = 0;
    _time = nil;
}

@end
