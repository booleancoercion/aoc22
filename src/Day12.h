#import "Day.h"

OF_ASSUME_NONNULL_BEGIN

@interface Day12 : Day
- init OF_UNAVAILABLE;
@end

@interface HeightMap : IntMatrix
- (OFEnumerator<Point2 *> *)neighbors:(size_t)row col:(size_t)col anti:(BOOL)anti;
@end

OF_ASSUME_NONNULL_END
