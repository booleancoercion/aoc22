#import "Day09.h"

typedef enum {
    UP,
    LEFT,
    DOWN,
    RIGHT
} direction_t;

static void getDeltasFromDirection(direction_t direction, int *x, int *y) {
    switch(direction) {
    case UP:
        *y = 1;
        break;
    case LEFT:
        *x = -1;
        break;
    case DOWN:
        *y = -1;
        break;
    case RIGHT:
        *x = 1;
        break;
    }
}

@interface RopeInstruction : OFObject
@property(readonly, nonatomic) direction_t direction;
@property(readonly, nonatomic) int count;

+ (instancetype)ropeInstructionWithLine:(OFString *)line;
- (instancetype)initWithLine:(OFString *)line;
+ (instancetype)ropeInstructionWithDirectionAndCount:(direction_t)direction count:(int)count;
- (instancetype)initWithDirectionAndCount:(direction_t)direction count:(int)count;
@end

@implementation RopeInstruction
+ (instancetype)ropeInstructionWithLine:(OFString *)line {
    return [[self alloc] initWithLine:line];
}

- (instancetype)initWithLine:(OFString *)line {
    char directionChar = [line characterAtIndex:0];
    direction_t direction;
    switch(directionChar) {
    case 'U':
        direction = UP;
        break;
    case 'L':
        direction = LEFT;
        break;
    case 'D':
        direction = DOWN;
        break;
    case 'R':
        direction = RIGHT;
        break;
    default:
        @throw @"Invalid character for direction!";
    }

    OFRange countRange = {.location = 2, .length = line.length - 2};
    int count = [line substringWithRange:countRange].longLongValue;

    return [self initWithDirectionAndCount:direction count:count];
}

+ (instancetype)ropeInstructionWithDirectionAndCount:(direction_t)direction count:(int)count {
    return [[self alloc] initWithDirectionAndCount:direction count:count];
}

- (instancetype)initWithDirectionAndCount:(direction_t)direction count:(int)count {
    self = [super init];
    _direction = direction;
    _count = count;
    return self;
}
@end

@interface Rope : OFObject
@property(readonly, nonatomic) Point2 *head;
@property(readonly, nonatomic) Point2 *tail;

- (instancetype)initWithTrack:(BOOL)trackVisits;
- init OF_UNAVAILABLE;

- (void)setHeadPos:(int)x y:(int)y;
- (void)moveOne:(direction_t)direction;
- (int)getNumberOfVisitedTiles;
@end

@implementation Rope {
    OFMutableSet<Point2 *> *_Nullable _visited;
}

- (instancetype)initWithTrack:(BOOL)trackVisits {
    self = [super init];
    _head = [Point2 point];
    _tail = [Point2 point];

    if(trackVisits) {
        _visited = [OFMutableSet set];
        [_visited addObject:_tail.copy];
    } else {
        _visited = nil;
    }

    return self;
}

- (void)setHeadPos:(int)x y:(int)y {
    if(abs(self.head.x - x) > 1 || abs(self.head.y - y) > 1) {
        @throw @"setHeadPos assertion failed";
    }

    self.head.x = x;
    self.head.y = y;

    let lInfDist = max(abs(self.head.x - self.tail.x), abs(self.head.y - self.tail.y));
    if(lInfDist <= 1) {
        // head is touching tail, so no need to move the tail
        return;
    }

    // easy cases

    if(self.head.x == self.tail.x) {
        if(self.head.y > self.tail.y) {
            self.tail.y += 1;
        } else {
            self.tail.y -= 1;
        }
    } else if(self.head.y == self.tail.y) {
        if(self.head.x > self.tail.x) {
            self.tail.x += 1;
        } else {
            self.tail.x -= 1;
        }
    }
    // diagonal case
    else {
        self.tail.x += self.head.x > self.tail.x ? 1 : -1;
        self.tail.y += self.head.y > self.tail.y ? 1 : -1;
    }

    if(_visited) {
        [_visited addObject:self.tail.copy];
    }
}

- (void)moveOne:(direction_t)direction {
    int x = 0, y = 0;
    getDeltasFromDirection(direction, &x, &y);

    [self setHeadPos:self.head.x + x y:self.head.y + y];
}

- (int)getNumberOfVisitedTiles {
    return _visited.count;
}
@end

@implementation Day09 {
    OFArray<RopeInstruction *> *_instructions;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    OFMutableArray<RopeInstruction *> *instructions = [OFMutableArray array];
    OFString *line;
    while((line = [stream readLine])) {
        let inst = [RopeInstruction ropeInstructionWithLine:line];
        [instructions addObject:inst];
    }

    [instructions makeImmutable];
    _instructions = instructions;

    return self;
}

- (OFObject *)runPart1 {
    let rope = [[Rope alloc] initWithTrack:true];

    for(RopeInstruction *instruction in _instructions) {
        for(size_t i = 0; i < instruction.count; i++) {
            [rope moveOne:instruction.direction];
        }
    }
    return @([rope getNumberOfVisitedTiles]);
}

- (OFObject *)runPart2 {
    const size_t KNOTS = 10;
    const size_t NUM_ROPES = KNOTS - 1;

    Rope *ropes[NUM_ROPES];

    for(size_t i = 0; i < NUM_ROPES - 1; i++) {
        ropes[i] = [[Rope alloc] initWithTrack:NO];
    }
    ropes[NUM_ROPES - 1] = [[Rope alloc] initWithTrack:YES];

    for(RopeInstruction *instruction in _instructions) {
        for(size_t insti = 0; insti < instruction.count; insti++) {
            [ropes[0] moveOne:instruction.direction];
            for(size_t i = 1; i < NUM_ROPES; i++) {
                Point2 *prevTail = ropes[i - 1].tail;
                [ropes[i] setHeadPos:prevTail.x y:prevTail.y];
            }
        }
    }

    return @([ropes[NUM_ROPES - 1] getNumberOfVisitedTiles]);
}
@end
