#import <ObjFW/ObjFW.h>

#define var __auto_type
#define let const var

OF_ASSUME_NONNULL_BEGIN

@interface Day : OFObject
+ (instancetype)dayWithStream:(OFStream *)stream;

- (instancetype)initWithStream:(OFStream *)stream;

- (OFObject *)runPart1;
- (OFObject *)runPart2;
@end

OF_ASSUME_NONNULL_END
