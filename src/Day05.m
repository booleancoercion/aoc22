#import "Day05.h"

@interface Move : OFObject
@property(readonly, nonatomic) int amount;
@property(readonly, nonatomic) size_t from, to;

+ (instancetype)moveWithAmountFromTo:(int)amount from:(size_t)from to:(size_t)to;
+ (instancetype)moveWithLine:(OFString *)line;
- (instancetype)initWithAmountFromTo:(int)amount from:(size_t)from to:(size_t)to;
- (instancetype)initWithLine:(OFString *)line;
- init OF_UNAVAILABLE;
@end

@implementation Move
+ (instancetype)moveWithAmountFromTo:(int)amount from:(size_t)from to:(size_t)to {
    return [[self alloc] initWithAmountFromTo:amount from:from to:to];
}

+ (instancetype)moveWithLine:(OFString *)line {
    return [[self alloc] initWithLine:line];
}

- (instancetype)initWithAmountFromTo:(int)amount from:(size_t)from to:(size_t)to {
    self = [super init];
    if(self) {
        _amount = amount;
        _from = from;
        _to = to;
    }
    return self;
}

- (instancetype)initWithLine:(OFString *)line {
    let charset = [OFCharacterSet characterSetWithCharactersInString:@"movefrt "];
    let numbers = [line componentsSeparatedByCharactersInSet:charset
                                                     options:OFStringSkipEmptyComponents];

    let amount = numbers[0].longLongValue;
    let from = numbers[1].longLongValue - 1;
    let to = numbers[2].longLongValue - 1;

    return [self initWithAmountFromTo:amount from:from to:to];
}
@end

@implementation Day05 {
    OFArray<OFArray<OFNumber *> *> *_crates;
    OFArray<Move *> *_moves;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];
    if(self) {
        OFMutableArray<OFString *> *lines = [OFMutableArray array];

        OFString *line;
        while((line = [stream readLine])) {
            [lines addObject:line];
        }

        let sepIdx = [lines indexOfObject:@""];
        if(sepIdx == OFNotFound) {
            @throw @"separator not found!";
        }

        // we also don't want to include the line before the separator
        OFRange fst = {.location = 0, .length = sepIdx - 1};
        OFRange snd = {.location = sepIdx + 1, .length = lines.count - sepIdx - 1};
        let crateLines = [lines objectsInRange:fst];
        let moveLines = [lines objectsInRange:snd];

        // crate parsing

        // each crate takes up 4 chars of space (`[_] `), except for the last one which
        // takes 3 chars since it has no space.
        let numCrates = (crateLines[0].length + 1) / 4;
        let crates = [OFMutableArray<OFArray<OFNumber *> *> array];

        for(size_t i = 0; i < numCrates; i++) {
            let idx = 4 * i + 1;
            let crate = [OFMutableArray<OFNumber *> array];
            for(int j = crateLines.count - 1; j >= 0; j--) {
                char c = [crateLines[j] characterAtIndex:idx];
                if(c == ' ') {
                    break;
                }
                [crate addObject:@(c)];
            }

            [crates addObject:crate];
        }
        _crates = crates;

        // move parsing
        _moves = [moveLines mappedArrayUsingBlock:^(OFString *obj, size_t _) {
            return [Move moveWithLine:obj];
        }];
    }
    return self;
}

- (OFString *)runPart1 {
    let buffers = [_crates mappedArrayUsingBlock:^(OFArray<OFNumber *> *crate, size_t _) {
        return [OFMutableArray arrayWithArray:crate];
    }];

    for(Move *move in _moves) {
        OFMutableArray<OFNumber *> *from = buffers[move.from];
        OFMutableArray<OFNumber *> *to = buffers[move.to];
        for(int i = 0; i < move.amount; i++) {
            [to addObject:from.lastObject];
            [from removeLastObject];
        }
    }

    let result = [OFMutableString string];
    for(OFArray<OFNumber *> *buffer in buffers) {
        OFUnichar c = buffer.lastObject.charValue;
        [result appendCharacters:&c length:1];
    }
    return result;
}

- (OFString *)runPart2 {
    let buffers = [_crates mappedArrayUsingBlock:^(OFArray<OFNumber *> *crate, size_t _) {
        return [OFMutableArray arrayWithArray:crate];
    }];

    for(Move *move in _moves) {
        OFMutableArray<OFNumber *> *from = buffers[move.from];
        OFMutableArray<OFNumber *> *to = buffers[move.to];

        OFRange range = {.location = from.count - move.amount, .length = move.amount};
        let objects = [from objectsInRange:range];
        [to addObjectsFromArray:objects];
        [from removeObjectsInRange:range];
    }

    let result = [OFMutableString string];
    for(OFArray<OFNumber *> *buffer in buffers) {
        OFUnichar c = buffer.lastObject.charValue;
        [result appendCharacters:&c length:1];
    }
    return result;
}
@end
