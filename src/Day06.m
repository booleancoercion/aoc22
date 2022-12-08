#import "Day06.h"

@implementation Day06 {
    OFString *_inner;
    size_t _len;
    const char *_chars;

    int _counts[26];
    int _higherThanOne;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    _inner = [stream readLine]; // there is only 1 line
    _len = [_inner UTF8StringLength];
    _chars = [_inner UTF8String]; // utf8 contains ascii so this is fine

    return self;
}

- (void)addToCounts:(char)ch {
    size_t idx = ch - 'a';
    _counts[idx] += 1;
    if(_counts[idx] == 2) {
        _higherThanOne += 1;
    }
}

- (void)removeFromCounts:(char)ch {
    size_t idx = ch - 'a';
    _counts[idx] -= 1;
    if(_counts[idx] == 1) {
        _higherThanOne -= 1;
    }
}

- (OFNumber *)doPart:(int)packetSize {
    memset(_counts, 0, sizeof(_counts));
    _higherThanOne = 0;

    for(int i = 0; i < packetSize; i++) {
        [self addToCounts:_chars[i]];
    }

    if(_higherThanOne == 0) {
        return @(packetSize);
    }

    for(int i = 0; i < _len - packetSize; i++) {
        [self removeFromCounts:_chars[i]];
        [self addToCounts:_chars[i + packetSize]];

        if(_higherThanOne == 0) {
            return @(i + packetSize + 1);
        }
    }

    return nil;
}

- (OFNumber *)runPart1 {
    return [self doPart:4];
}

- (OFNumber *)runPart2 {
    return [self doPart:14];
}
@end
