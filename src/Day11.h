#import "Day.h"

typedef long long item_t;

OF_ASSUME_NONNULL_BEGIN

@interface Day11 : Day
- init OF_UNAVAILABLE;
@end

@interface Operation : OFObject
- (item_t)perform:(item_t)worryLevel;
+ (instancetype)parse:(OFString *)line;
@end

@interface OpAdd : Operation
@property(nonatomic, readonly) item_t amount;

- init OF_UNAVAILABLE;
- (instancetype)initWithAmount:(item_t)amount;
@end

@interface OpMul : Operation
@property(nonatomic, readonly) item_t amount;

- init OF_UNAVAILABLE;
- (instancetype)initWithAmount:(item_t)amount;
@end

@interface OpSquare : Operation
@end

@interface Monkey : OFObject <OFComparing, OFMutableCopying>
@property(nonatomic, readonly) LongVec *items;
@property(nonatomic, readonly) Operation *operation;
@property(nonatomic, readonly) item_t test;
@property(nonatomic, readonly) size_t trueMonkey;
@property(nonatomic, readonly) size_t falseMonkey;
@property(nonatomic, readonly) item_t inspections;

- init OF_UNAVAILABLE;
- (instancetype)initWithStream:(OFStream *)stream;
- (instancetype)initWithEverything:(LongVec *)items
                         operation:(Operation *)operation
                              test:(item_t)test
                        trueMonkey:(size_t)trueMonkey
                       falseMonkey:(size_t)falseMonkey;

- (void)takeTurn:(OFArray<Monkey *> *)monkeys
          modulus:(item_t)modulus
    divideByThree:(BOOL)divideByThree;
@end

OF_ASSUME_NONNULL_END
