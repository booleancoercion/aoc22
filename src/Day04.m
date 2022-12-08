#import "Day04.h"

void splitRange(OFString *input, int *out1, int *out2) {
    var parts = [input componentsSeparatedByString:@"-"];
    *out1 = parts[0].longLongValue;
    *out2 = parts[1].longLongValue;
}

@interface ElfPair : OFObject
@property(nonatomic, readonly) int x1;
@property(nonatomic, readonly) int x2;
@property(nonatomic, readonly) int y1;
@property(nonatomic, readonly) int y2;

+ (instancetype)elfPairWithLine:(OFString *)line;
+ (instancetype)elfPairWithRanges:(int)x1 endx:(int)x2 starty:(int)y1 endy:(int)y2;
- (instancetype)initWithLine:(OFString *)line;
- (instancetype)initWithRanges:(int)x1 endx:(int)x2 starty:(int)y1 endy:(int)y2;

- (BOOL)xContainsY;
- (BOOL)yContainsX;

@end

@implementation ElfPair
+ (instancetype)elfPairWithLine:(OFString *)line {
    return [[self alloc] initWithLine:line];
}

+ (instancetype)elfPairWithRanges:(int)x1 endx:(int)x2 starty:(int)y1 endy:(int)y2 {
    return [[self alloc] initWithRanges:x1 endx:x2 starty:y1 endy:y2];
}

- (instancetype)initWithLine:(OFString *)line {
    var parts = [line componentsSeparatedByString:@","];
    int x1, x2, y1, y2;
    splitRange(parts[0], &x1, &x2);
    splitRange(parts[1], &y1, &y2);

    return [self initWithRanges:x1 endx:x2 starty:y1 endy:y2];
}

- (instancetype)initWithRanges:(int)x1 endx:(int)x2 starty:(int)y1 endy:(int)y2 {
    self = [super init];

    if(x1 > x2 || y1 > y2) {
        @throw @"Invalid range!";
    }
    _x1 = x1;
    _x2 = x2;
    _y1 = y1;
    _y2 = y2;

    return self;
}

- (BOOL)xContainsY {
    return self.x1 <= self.y1 && self.y2 <= self.x2;
}
- (BOOL)yContainsX {
    return self.y1 <= self.x1 && self.x2 <= self.y2;
}
- (BOOL)rangesOverlap {
    return (self.x1 <= self.y1 && self.y1 <= self.x2) || (self.y1 <= self.x1 && self.x1 <= self.y2);
}
@end

@implementation Day04 {
    OFArray<ElfPair *> *_pairs;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    var pairs = [OFMutableArray<ElfPair *> array];

    OFString *line;
    while((line = [stream readLine])) {
        [pairs addObject:[ElfPair elfPairWithLine:line]];
    }
    _pairs = pairs;

    return self;
}

- (OFValue *)runPart1 {
    int sum = 0;
    for(ElfPair *pair in _pairs) {
        if([pair xContainsY] || [pair yContainsX])
            sum++;
    }

    return @(sum);
}

- (OFValue *)runPart2 {
    int sum = 0;
    for(ElfPair *pair in _pairs) {
        if([pair rangesOverlap])
            sum++;
    }

    return @(sum);
}
@end
