#import "Day10.h"

@interface ScreenInstruction : OFObject
+ (instancetype)parse:(OFString *)str;
+ (int)numCycles;
@end

@interface Addx : ScreenInstruction
@property(nonatomic) int amount;

- init OF_UNAVAILABLE;
- (instancetype)initWithAmount:(int)amount;
@end

@interface Noop : ScreenInstruction
@end

@implementation Day10 {
    OFArray<ScreenInstruction *> *_instructions;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    OFMutableArray *instructions = [OFMutableArray array];

    OFString *line;
    while((line = [stream readLine])) {
        [instructions addObject:[ScreenInstruction parse:line]];
    }

    [instructions makeImmutable];
    _instructions = instructions;

    return self;
}

#define NUM_STOPS 6
const int STOPS[NUM_STOPS] = {20, 60, 100, 140, 180, 220};

- (OFObject *)runPart1 {
    int x = 1;
    size_t cycle = 0;
    int score = 0;

    size_t current_stop = 0;

    for(ScreenInstruction *instruction in _instructions) {
        size_t deltaCycles = [[instruction class] numCycles];

        if(cycle + deltaCycles >= STOPS[current_stop]) {
            score += STOPS[current_stop] * x;
            current_stop += 1;
        }

        if(current_stop >= NUM_STOPS) {
            break;
        }

        if([instruction isMemberOfClass:[Addx class]]) {
            Addx *addx = (Addx *)instruction;
            x += addx.amount;
        } else if([instruction isMemberOfClass:[Noop class]]) {
            // do nothing
        } else {
            @throw @"Invalid screen instruction instance";
        }

        cycle += deltaCycles;
    }

    return @(score);
}

- (OFObject *)runPart2 {
    OFMutableString *crt = [OFMutableString stringWithString:@"\n"];
    const size_t HEIGHT = 6;
    const size_t WIDTH = 40;

    int reg = 1;
    size_t cycle = 0;

    let enumerator = [_instructions objectEnumerator];
    var latestInstruction = [enumerator nextObject];

    size_t screenCycle = 0;
    for(size_t y = 0; y < HEIGHT; y++) {
        for(size_t x = 0; x < WIDTH; x++) {
            screenCycle += 1;

            if(abs(reg - (int)x) <= 1) {
                [crt appendString:@"#"];
            } else {
                [crt appendString:@" "];
            }

            if(cycle < screenCycle) {
                cycle += [[latestInstruction class] numCycles];
            }

            if(cycle == screenCycle) {
                if([latestInstruction isMemberOfClass:[Addx class]]) {
                    Addx *addx = (Addx *)latestInstruction;
                    reg += addx.amount;
                }
                latestInstruction = [enumerator nextObject];
            }
        }
        [crt appendString:@"\n"];
    }
    return crt;
}
@end

@implementation ScreenInstruction
+ (instancetype)parse:(OFString *)str {
    let splut = [str componentsSeparatedByString:@" "];
    if([splut[0] isEqual:@"noop"]) {
        return [Noop new];
    } else if([splut[0] isEqual:@"addx"]) {
        return [[Addx alloc] initWithAmount:splut[1].longLongValue];
    } else {
        @throw @"Invalid screen instruction string";
    }
}

+ (int)numCycles {
    OF_UNRECOGNIZED_SELECTOR
}
@end

@implementation Addx
- (instancetype)initWithAmount:(int)amount {
    self = [super init];
    _amount = amount;
    return self;
}

+ (int)numCycles {
    return 2;
}
@end

@implementation Noop
+ (int)numCycles {
    return 1;
}
@end
