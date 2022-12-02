#import "Day01.h"

typedef OFArray<OFNumber *> *Elf;

@implementation Day01 {
  @private
    OFArray<Elf> *_elves;
}

- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    OFMutableArray<OFMutableArray<OFNumber *> *> *elves = [OFMutableArray array];
    OFMutableArray<OFNumber *> *latestElf = [OFMutableArray array];
    [elves addObject:latestElf];

    OFString *line;
    while((line = [stream readLine])) {
        line = [line stringByDeletingEnclosingWhitespaces];

        if([line length] == 0) {
            latestElf = [OFMutableArray array];
            [elves addObject:latestElf];
        } else {
            [latestElf addObject:@(line.longLongValue)];
        }
    }

    _elves = (OFArray<Elf> *)elves;
    return self;
}

- (OFArray<OFNumber *> *)elvesSummed {
    return [_elves mappedArrayUsingBlock:^(Elf elf, size_t _) {
        return [elf foldUsingBlock:^(OFNumber *num1, OFNumber *num2) {
            return @(num1.intValue + num2.intValue);
        }];
    }];
}

- (OFNumber *)runPart1 {
    return [[self elvesSummed] foldUsingBlock:^(OFNumber *num1, OFNumber *num2) {
        if([num1 compare:num2] == OFOrderedAscending) {
            return num2;
        } else {
            return num1;
        }
    }];
}

- (OFNumber *)runPart2 {
    OFArray<OFNumber *> *sortedElves = [[[self elvesSummed] sortedArray] reversedArray];

    return @(sortedElves[0].intValue + sortedElves[1].intValue + sortedElves[2].intValue);
}

- (OFString *)description {
    return [_elves description];
}

@end
