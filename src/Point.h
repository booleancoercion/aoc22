#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface Point2 : OFObject <OFCopying>
@property(nonatomic) int x;
@property(nonatomic) int y;

+ (instancetype)pointWithCoordinates:(int)x y:(int)y;
- (instancetype)initWithCoordinates:(int)x y:(int)y;
+ (instancetype)point;

@end

OF_ASSUME_NONNULL_END
