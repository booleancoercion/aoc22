#import "Day03.h"

size_t getIndex(char c) {
    if(c >= 'a' && c <= 'z') {
        return c - 'a';
    } else if(c >= 'A' && c <= 'Z') {
        return c - 'A' + 26;
    } else {
        @throw @"Invalid char";
    }
}

@interface Rucksack : OFObject
+ (instancetype)rucksackWithLine:(OFString *)line;
- (instancetype)initWithLine:(OFString *)line;

- (char)getCharWithTwoAppearances:(int *)buffer;
- (size_t)addSelfToBuffer:(int *)buffer offset:(size_t)offset;
@end

@implementation Rucksack {
    OFString *__strong _line; // to make sure the char pointers don't deallocate too early
    const char *_comp1;
    const char *_comp2;
    size_t _len;
}
+ (instancetype)rucksackWithLine:(OFString *)line {
    return [[self alloc] initWithLine:line];
}

// This method expects `line` to have no whitespace.
- (instancetype)initWithLine:(OFString *)line {
    self = [super init];

    _line = line;
    _len = [line cStringLengthWithEncoding:OFStringEncodingUTF8] >> 1;
    _comp1 = [line cStringWithEncoding:OFStringEncodingUTF8];
    _comp2 = &_comp1[_len];

    return self;
}

// `buffer` must have a length of at least 52
- (char)getCharWithTwoAppearances:(int *)buffer {
    memset(buffer, 0, 52 * sizeof(*buffer));

    for(size_t i = 0; i < _len; i++) {
        char c1 = _comp1[i], c2 = _comp2[i];
        size_t i1 = getIndex(c1), i2 = getIndex(c2);
        buffer[i1] |= 1;
        buffer[i2] |= 2;

        if(buffer[i1] == 3) {
            return c1;
        } else if(buffer[i2] == 3) {
            return c2;
        }
    }

    @throw @"Couldn't find a char that appears twice!";
}

// `buffer` must have a length of at least 52.
// the return value is the last index that was considered. this is useful for the 3rd rucksack,
// which will set an item to `7` for sure and then exit.
- (size_t)addSelfToBuffer:(int *)buffer offset:(size_t)offset {
    size_t idx;
    for(size_t i = 0; i < _len * 2; i++) {
        idx = getIndex(_comp1[i]);
        buffer[idx] |= (1 << offset);
        if(buffer[idx] == 7) {
            break;
        }
    }
    return idx;
}
@end

@implementation Day03 {
    OFArray<Rucksack *> *_rucksacks;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    OFMutableArray<Rucksack *> *rucksacks = [OFMutableArray array];

    OFString *line;
    while((line = [stream readLine])) {
        [rucksacks addObject:[Rucksack rucksackWithLine:line]];
    }

    _rucksacks = rucksacks;

    return self;
}
- (OFValue *)runPart1 {
    int sum = 0;
    int buffer[52] = {0};

    for(Rucksack *rucksack in _rucksacks) {
        char c = [rucksack getCharWithTwoAppearances:buffer];
        sum += getIndex(c) + 1;
    }

    return @(sum);
}
- (OFValue *)runPart2 {
    int sum = 0;
    int buffer[52];

    size_t i = 0;
    for(Rucksack *rucksack in _rucksacks) {
        if(i % 3 == 0) {
            memset(buffer, 0, 52 * sizeof(*buffer));
        }

        size_t idx = [rucksack addSelfToBuffer:buffer offset:i % 3];

        if(i % 3 == 2) {
            sum += idx + 1;
        }

        i++;
    }

    return @(sum);
}
@end
