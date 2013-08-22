#import <Foundation/Foundation.h>

extern NSString *const SFErrorDomain;

typedef NS_ENUM(NSInteger, SFErrorCode) {
    SFErrorCode_None = 0,
    SFErrorCode_Memory = 1,
    SFErrorCode_Internal = 2,
    SFErrorCode_AuthRequired = 3,
    SFErrorCode_InvalidArgument = 4
};

NSError * errorWithCode(SFErrorCode errorCode);