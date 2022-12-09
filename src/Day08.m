#import "Day08.h"
#import "IntMatrix.h"

@implementation Day08 {
    IntMatrix *_trees;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    let data = [stream readDataUntilEndOfStream];
    let string = [OFString stringWithData:data encoding:OFStringEncodingASCII];

    __block size_t lineLength = 0;
    __block size_t lineCount = 0;
    [string enumerateLinesUsingBlock:^(OFString *line, BOOL *stop) {
        if([line isEqual:@""]) {
            *stop = YES;
            return;
        }

        if(lineLength == 0) {
            lineLength = line.length;
        }

        lineCount += 1;
    }];

    _trees = [IntMatrix matrixWithWidthHeightValue:lineLength height:lineCount value:0];

    let chars = [string UTF8String];
    let len = [string UTF8StringLength];

    size_t matIdx = 0;
    for(size_t idx = 0; idx < len; idx++) {
        if(chars[idx] == '\n') {
            continue;
        }

        [_trees setRaw:matIdx value:chars[idx] - '0'];

        matIdx += 1;
    }

    return self;
}

- (OFObject *)runPart1 {
    __block let minHeightBuffer = [IntMatrix matrixWithWidthHeightValue:_trees.width
                                                                 height:_trees.height
                                                                  value:10];

    __block size_t minHeight = 0;

    let updateMinHeight = ^(size_t row, size_t col) {
        if([minHeightBuffer get:row col:col] > minHeight) {
            [minHeightBuffer set:row col:col value:minHeight];
        }

        int tree = [_trees get:row col:col];
        if(tree + 1 > minHeight) {
            minHeight = tree + 1;
        }
    };

    for(size_t row = 0; row < minHeightBuffer.height; row++) {
        minHeight = 0;
        for(size_t col = 0; col < minHeightBuffer.width; col++) {
            updateMinHeight(row, col);
        }

        minHeight = 0;
        for(size_t col = 0; col < minHeightBuffer.width; col++) {
            updateMinHeight(row, minHeightBuffer.width - col - 1);
        }
    }

    for(size_t col = 0; col < minHeightBuffer.width; col++) {
        minHeight = 0;
        for(size_t row = 0; row < minHeightBuffer.height; row++) {
            updateMinHeight(row, col);
        }

        minHeight = 0;
        for(size_t row = 0; row < minHeightBuffer.height; row++) {
            updateMinHeight(minHeightBuffer.height - row - 1, col);
        }
    }

    int count = 0;
    for(size_t idx = 0; idx < _trees.width * _trees.height; idx++) {
        if([_trees getRaw:idx] >= [minHeightBuffer getRaw:idx]) {
            count += 1;
        }
    }

    return @(count);
}

- (OFObject *)runPart2 {
    // left, right, up, down
    IntMatrix *viewDistances[4] = {nil, nil, nil, nil};
    for(size_t i = 0; i < 4; i++) {
        viewDistances[i] = [IntMatrix matrixWithWidthHeightValue:_trees.width
                                                          height:_trees.height
                                                           value:0];
    }

    size_t nearestGeqTo[10];
    // objective c doesn't allow arrays to be captured?
    __block size_t *nearestGeqToPtr = nearestGeqTo;

    let resetNearest = ^(size_t value) {
        for(size_t i = 0; i < 10; i++) {
            nearestGeqToPtr[i] = value;
        }
    };

    let updateNearest = ^(IntMatrix *viewDistance, size_t row, size_t col, size_t significant) {
        int tree = [_trees get:row col:col];
        size_t nearestIdx = nearestGeqToPtr[tree];
        int value = nearestIdx > significant ? nearestIdx - significant : significant - nearestIdx;
        [viewDistance set:row col:col value:value];

        for(size_t i = 0; i <= tree; i++) {
            nearestGeqToPtr[i] = significant;
        }
    };

    for(size_t row = 0; row < _trees.height; row++) {
        resetNearest(0);
        for(size_t col = 0; col < _trees.width; col++) {
            updateNearest(viewDistances[0], row, col, col);
        }

        resetNearest(_trees.width - 1);
        for(size_t col = 0; col < _trees.width; col++) {
            updateNearest(viewDistances[1], row, _trees.width - col - 1, _trees.width - col - 1);
        }
    }

    for(size_t col = 0; col < _trees.width; col++) {
        resetNearest(0);
        for(size_t row = 0; row < _trees.height; row++) {
            updateNearest(viewDistances[2], row, col, row);
        }

        resetNearest(_trees.height - 1);
        for(size_t row = 0; row < _trees.height; row++) {
            updateNearest(viewDistances[3], _trees.height - row - 1, col, _trees.height - row - 1);
        }
    }

    long long maxScore = 0;
    for(size_t idx = 0; idx < _trees.width * _trees.height; idx++) {
        long long score = 1;
        for(size_t i = 0; i < 4; i++) {
            score *= [viewDistances[i] getRaw:idx];
        }

        if(score > maxScore) {
            maxScore = score;
        }
    }

    return @(maxScore);
}
@end
