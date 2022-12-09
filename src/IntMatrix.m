#import "IntMatrix.h"

#define GET_INNER_IDX(row, col) (self.width * (row) + (col))

@implementation IntMatrix {
    int *_inner;
}

+ (instancetype)matrixWithWidthHeightValue:(size_t)width height:(size_t)height value:(int)value {
    return [[self alloc] initWithWidthHeightValue:width height:height value:value];
}

- (instancetype)initWithWidthHeightValue:(size_t)width height:(size_t)height value:(int)value {
    self = [super init];

    if(width == 0 || height == 0) {
        @throw [OFInitializationFailedException exceptionWithClass:[self class]];
    }

    _width = width;
    _height = height;

    _inner = OFAllocMemory(width * height, sizeof(*_inner));

    for(size_t idx = 0; idx < width * height; idx++) {
        _inner[idx] = value;
    }

    _inner = [[OFMutableData dataWithItemsNoCopy:_inner
                                           count:width * height * sizeof(*_inner)
                                    freeWhenDone:YES] mutableItems];

    return self;
}

- (int)get:(size_t)row col:(size_t)col {
    if(row >= self.height || col >= self.width) {
        @throw [OFOutOfRangeException exception];
    }

    return [self getRaw:GET_INNER_IDX(row, col)];
}

- (void)set:(size_t)row col:(size_t)col value:(int)value {
    if(row >= self.height || col >= self.width) {
        @throw [OFOutOfRangeException exception];
    }

    [self setRaw:GET_INNER_IDX(row, col) value:value];
}

- (void)setRaw:(size_t)idx value:(int)value {
    _inner[idx] = value;
}
- (int)getRaw:(size_t)idx {
    return _inner[idx];
}

- (OFString *)description {
    OFMutableString *buffer = [OFMutableString string];

    for(size_t idx = 0; idx < self.width * self.height; idx++) {
        OFUnichar ch = _inner[idx] + '0';
        [buffer appendCharacters:&ch length:1];

        if(idx % self.width == self.width - 1) {
            ch = '\n';
            [buffer appendCharacters:&ch length:1];
        }
    }

    [buffer makeImmutable];
    return buffer;
}
@end
