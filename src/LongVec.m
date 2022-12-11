#import "LongVec.h"

#define LONG_VEC_INITIAL_CAPACITY 4

@implementation LongVec {
    LongVecItem *_items;
    size_t _capacity;
}

- (instancetype)init {
    return [self initWithCapacity:LONG_VEC_INITIAL_CAPACITY];
}

- (instancetype)initWithCapacity:(size_t)capacity {
    self = [super init];

    _capacity = capacity;
    _length = 0;
    _items = calloc(_capacity, sizeof(LongVecItem));

    return self;
}

- (LongVecItem)getItem:(size_t)idx {
    if(idx >= _length) {
        @throw
            [OFString stringWithFormat:@"Index out of range (the length is %d but the index is %d)",
                                       _length, idx];
    }

    return _items[idx];
}

- (void)setItem:(size_t)idx value:(LongVecItem)value {
    if(idx >= _length) {
        @throw
            [OFString stringWithFormat:@"Index out of range (the length is %d but the index is %d)",
                                       _length, idx];
    }

    _items[idx] = value;
}

- (void)pushItem:(LongVecItem)value {
    if(_capacity == _length) {
        _capacity *= 2;
        _items = realloc(_items, _capacity * sizeof(LongVecItem));
    }

    _items[_length] = value;
    _length += 1;
}

- (LongVecItem)popItem {
    if(_length == 0) {
        @throw @"Called pop on an empty vector";
    }

    _length -= 1;
    return _items[_length];
}

- (void)clearAllItems {
    _length = 0;
}

- (void)dealloc {
    free(_items);
}

- (instancetype)mutableCopy {
    LongVec *copy = [[LongVec alloc] initWithCapacity:_capacity];

    copy->_length = _length;
    memcpy(copy->_items, _items, _length * sizeof(LongVecItem));

    return copy;
}

- (OFString *)description {
    OFMutableString *str = [OFMutableString string];

    for(size_t i = 0; i < _length; i++) {
        if(i + 1 == _length) {
            [str appendFormat:@"%lld", _items[i]];
        } else {
            [str appendFormat:@"%lld, ", _items[i]];
        }
    }

    return str;
}

@end
