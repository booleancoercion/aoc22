#import "Day11.h"

@implementation Day11 {
    OFArray<Monkey *> *_monkeys;
    item_t _modulus;
}

- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    OFMutableArray<Monkey *> *monkeys = [OFMutableArray array];

    while(![stream isAtEndOfStream]) {
        [monkeys addObject:[[Monkey alloc] initWithStream:stream]];
    }

    [monkeys makeImmutable];
    _monkeys = monkeys;

    _modulus = 1;
    for(Monkey *monkey in monkeys) {
        _modulus *= monkey.test;
    }

    return self;
}

- (OFObject *)runPart1 {
    const size_t ROUNDS = 20;

    OFArray<Monkey *> *monkeys = [_monkeys mappedArrayUsingBlock:^(Monkey *monkey, size_t _) {
        return monkey.mutableCopy;
    }];

    for(size_t i = 0; i < ROUNDS; i++) {
        for(Monkey *monkey in monkeys) {
            [monkey takeTurn:monkeys modulus:_modulus divideByThree:YES];
        }
    }

    let sorted = [monkeys sortedArrayUsingSelector:@selector(compare:)
                                           options:OFArraySortDescending];
    return @(sorted[0].inspections * sorted[1].inspections);
}

- (OFObject *)runPart2 {
    const size_t ROUNDS = 10000;

    OFArray<Monkey *> *monkeys = [_monkeys mappedArrayUsingBlock:^(Monkey *monkey, size_t _) {
        return monkey.mutableCopy;
    }];

    for(size_t i = 0; i < ROUNDS; i++) {
        for(Monkey *monkey in monkeys) {
            [monkey takeTurn:monkeys modulus:_modulus divideByThree:NO];
        }
    }

    let sorted = [monkeys sortedArrayUsingSelector:@selector(compare:)
                                           options:OFArraySortDescending];
    return @(sorted[0].inspections * sorted[1].inspections);
}
@end

@implementation Monkey
- (void)takeTurn:(OFArray<Monkey *> *)monkeys
          modulus:(item_t)modulus
    divideByThree:(BOOL)divideByThree {
    for(size_t i = 0; i < self.items.length; i++) {
        var number = [self.items getItem:i];
        number = [self.operation perform:number] % modulus;
        if(divideByThree) {
            number /= 3;
        }

        Monkey *other;
        if(number % self.test == 0) {
            other = monkeys[self.trueMonkey];
        } else {
            other = monkeys[self.falseMonkey];
        }

        [other.items pushItem:number];
        _inspections += 1;
    }

    [self.items clearAllItems];
}

- (instancetype)initWithStream:(OFStream *)stream {
    [stream readLine]; // skip the first line, it's just a header

    let startingCharset = [OFCharacterSet characterSetWithCharactersInString:@"Staringems:, "];
    let startingItems =
        [[stream readLine] componentsSeparatedByCharactersInSet:startingCharset
                                                        options:OFStringSkipEmptyComponents];

    let mutableStartingItems = [[LongVec alloc] init];
    for(OFString *item in startingItems) {
        [mutableStartingItems pushItem:item.longLongValue];
    }

    let operation = [Operation parse:[stream readLine]];
    let test = [[stream readLine] componentsSeparatedByString:@" "
                                                      options:OFStringSkipEmptyComponents][3]
                   .longLongValue;
    let trueMonkey = [[stream readLine] componentsSeparatedByString:@" "
                                                            options:OFStringSkipEmptyComponents][5]
                         .longLongValue;
    let falseMonkey = [[stream readLine] componentsSeparatedByString:@" "
                                                             options:OFStringSkipEmptyComponents][5]
                          .longLongValue;

    if(![stream isAtEndOfStream]) { // skip last empty line
        [stream readLine];
    }

    return [self initWithEverything:mutableStartingItems
                          operation:operation
                               test:test
                         trueMonkey:trueMonkey
                        falseMonkey:falseMonkey];
}

- (instancetype)initWithEverything:(LongVec *)items
                         operation:(Operation *)operation
                              test:(item_t)test
                        trueMonkey:(size_t)trueMonkey
                       falseMonkey:(size_t)falseMonkey {
    self = [super init];

    _items = items;
    _operation = operation;
    _test = test;
    _trueMonkey = trueMonkey;
    _falseMonkey = falseMonkey;
    _inspections = 0;

    return self;
}
- (OFComparisonResult)compare:(Monkey *)other {
    if(_inspections < other->_inspections) {
        return OFOrderedAscending;
    } else if(_inspections == other->_inspections) {
        return OFOrderedSame;
    } else {
        return OFOrderedDescending;
    }
}

- (instancetype)mutableCopy {
    return [[Monkey alloc] initWithEverything:self.items.mutableCopy
                                    operation:self.operation
                                         test:self.test
                                   trueMonkey:self.trueMonkey
                                  falseMonkey:self.falseMonkey];
}

@end

@implementation Operation
- (item_t)perform:(item_t)worryLevel {
    OF_UNRECOGNIZED_SELECTOR
}

+ (instancetype)parse:(OFString *)line {
    let parts = [line componentsSeparatedByString:@" " options:OFStringSkipEmptyComponents];
    let op = parts[4];
    let other = parts[5];

    if([op isEqual:@"*"]) {
        if([other isEqual:@"old"]) {
            return [OpSquare new];
        } else {
            return [[OpMul alloc] initWithAmount:other.longLongValue];
        }
    } else if([op isEqual:@"+"]) {
        return [[OpAdd alloc] initWithAmount:other.longLongValue];
    } else {
        @throw @"Invalid operation";
    }
}
@end

@implementation OpAdd
- (instancetype)initWithAmount:(item_t)amount {
    self = [super init];
    _amount = amount;
    return self;
}

- (item_t)perform:(item_t)worryLevel {
    return worryLevel + self.amount;
}
@end

@implementation OpMul
- (instancetype)initWithAmount:(item_t)amount {
    self = [super init];
    _amount = amount;
    return self;
}

- (item_t)perform:(item_t)worryLevel {
    return worryLevel * self.amount;
}
@end

@implementation OpSquare
- (item_t)perform:(item_t)worryLevel {
    return worryLevel * worryLevel;
}
@end
