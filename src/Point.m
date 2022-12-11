#import "Point.h"

@implementation Point2
- (instancetype)init {
    return [self initWithCoordinates:0 y:0];
}

+ (instancetype)point {
    return [[self alloc] init];
}

- (instancetype)initWithCoordinates:(int)x y:(int)y {
    self = [super init];
    _x = x;
    _y = y;
    return self;
}

+ (instancetype)pointWithCoordinates:(int)x y:(int)y {
    return [[self alloc] initWithCoordinates:x y:y];
}

- (int)manhattanDistance:(Point2 *)other {
    return abs(self.x - other.x) + abs(self.y - other.y);
}

- (OFString *)description {
    return [OFString stringWithFormat:@"(%d, %d)", self.x, self.y];
}
- (instancetype)copy {
    return [Point2 pointWithCoordinates:self.x y:self.y];
}

- (BOOL)isEqual:(Point2 *)other {
    // change this if using Point2 for comparison with superclasses!

    // i know this implementation is not the safest, but calling the getters has a lot of overhead.
    // class checking is additional overhead. this is a hot function, so i didn't want that here.
    return _x == other->_x && _y == other->_y;
}

- (unsigned long)hash {
    unsigned long prime = 31;
    unsigned long result = 1;

    result = prime * result + _x;
    result = prime * result + _y;

    return result;
}

@end
