#import "SFErrors.h"

NSString *const SFErrorDomain = @"SFErrorDomain";

NSError * errorWithCode(SFErrorCode errorCode) {
    NSString *message = nil;
    
    switch (errorCode) {
        case SFErrorCode_None:
            return nil;
            break;
            
        case SFErrorCode_Memory:
            message = @"Memory can not be allocated";
            break;
        
        case SFErrorCode_Internal:
            message = @"Internal error. Seems that something is wrong";
            break;
            
        case SFErrorCode_AuthRequired:
            message = @"You need to authorize before using client";
            break;
            
        case SFErrorCode_InvalidArgument:
            message = @"One or more input parameters are invalid";
            
        default:
            message = @"Refer to SFErrors.h for description";
            break;
    }
    
    NSDictionary *userInfo = (message) ? ([NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]) : (nil);
    return [NSError errorWithDomain:SFErrorDomain code:errorCode userInfo:userInfo];
}
