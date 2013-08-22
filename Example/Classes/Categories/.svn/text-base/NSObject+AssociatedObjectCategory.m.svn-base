#import <objc/runtime.h>
#import "NSObject+AssociatedObjectCategory.h"

static NSString *kAssociatedObject = @"kAssociatedObject";

@implementation NSObject (AssociatedObjectCategory)
@dynamic associatedObject;

- (void)setAssociatedObject:(id)object {
    objc_setAssociatedObject(self, (__bridge const void *)(kAssociatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, (__bridge const void *)(kAssociatedObject));
}

@end
