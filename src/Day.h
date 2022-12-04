#import <ObjFW/ObjFW.h>

#define var __auto_type
#define let const var

OF_ASSUME_NONNULL_BEGIN

@interface Day : OFObject
+ (instancetype)dayWithStream:(OFStream *)stream;

- (instancetype)initWithStream:(OFStream *)stream;

- (OFValue *)runPart1;
- (OFValue *)runPart2;
@end

OF_ASSUME_NONNULL_END
