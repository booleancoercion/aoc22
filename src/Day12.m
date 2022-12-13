#import "Day12.h"

@implementation Day12 {
    HeightMap *_heightMap;
    Point2 *_start;
    Point2 *_end;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    _heightMap = [HeightMap matrixWithStream:stream offsetChar:'a'];

    for(size_t row = 0; row < _heightMap.height; row++) {
        for(size_t col = 0; col < _heightMap.width; col++) {
            int got = [_heightMap get:row col:col] + 'a';
            if(got == 'S') {
                _start = [Point2 pointWithCoordinates:row y:col];
                [_heightMap set:row col:col value:0];
            } else if(got == 'E') {
                _end = [Point2 pointWithCoordinates:row y:col];
                [_heightMap set:row col:col value:'z' - 'a'];
            }
        }
    }

    return self;
}

- (OFObject *)shared:(BOOL)isPart1 {
    OFMutableArray<Point2 *> *queue = [OFMutableArray array];
    IntMatrix *explored = [IntMatrix matrixWithWidthHeightValue:_heightMap.width
                                                         height:_heightMap.height
                                                          value:-1];
    size_t idx = 0;

    Point2 *realStart;
    if(isPart1) {
        realStart = _start;
    } else {
        realStart = _end;
    }
    [explored set:realStart.x col:realStart.y value:0];
    [queue addObject:realStart];

    while(queue.count - idx > 0) {
        let current = queue[idx++];

        let currentNum = [explored get:current.x col:current.y];

        if((isPart1 && [current isEqual:_end]) || (!isPart1 && [_heightMap get:current.x
                                                                           col:current.y] == 0)) {
            return @(currentNum);
        }

        for(Point2 *neighbor in [_heightMap neighbors:current.x col:current.y anti:!isPart1]) {
            if([explored get:neighbor.x col:neighbor.y] == -1) {
                [explored set:neighbor.x col:neighbor.y value:currentNum + 1];
                [queue addObject:neighbor];
            }
        }
    }

    OF_UNREACHABLE
}

- (OFObject *)runPart1 {
    return [self shared:YES];
}

- (OFObject *)runPart2 {
    return [self shared:NO];
}
@end

@interface NeighborEnumerator : OFEnumerator <Point2 *>
- (instancetype)initWithMapAndPoint:(HeightMap *)map
                                row:(size_t)row
                                col:(size_t)col
                               anti:(BOOL)anti;
- init OF_UNAVAILABLE;
@end

@implementation NeighborEnumerator {
    HeightMap *__weak _map;
    size_t _row;
    size_t _col;
    BOOL _anti;

    size_t _deltaIdx;
}

- (instancetype)initWithMapAndPoint:(HeightMap *)map
                                row:(size_t)row
                                col:(size_t)col
                               anti:(BOOL)anti {
    self = [super init];

    _map = map;
    _row = row;
    _col = col;
    _deltaIdx = 0;
    _anti = anti;

    return self;
}

#define NUM_DELTAS 4
const static int deltaRow[NUM_DELTAS] = {-1, 0, 0, 1};
const static int deltaCol[NUM_DELTAS] = {0, -1, 1, 0};

- (nullable Point2 *)nextObject {
    while( // assert _deltaIdx is not out of bounds
        _deltaIdx < NUM_DELTAS &&

        // assert that the delta doesn't go outside the map from row's perspective
        (((deltaRow[_deltaIdx] < 0 && _row == 0) ||
          (deltaRow[_deltaIdx] > 0 && _row == _map.height - 1)) ||

         // assert that the delta doesn't go outside the map from col's perspective
         ((deltaCol[_deltaIdx] < 0 && _col == 0) ||
          (deltaCol[_deltaIdx] > 0 && _col == _map.width - 1)) ||

         // assert that the destination is not more than 1 block higher in the regular case
         (!_anti && ([_map get:_row col:_col] + 1 < [_map get:_row + deltaRow[_deltaIdx]
                                                          col:_col + deltaCol[_deltaIdx]])) ||

         // assert that the destination is not more than 1 block lower in the anti case
         (_anti && ([_map get:_row col:_col] - 1 > [_map get:_row + deltaRow[_deltaIdx]
                                                         col:_col + deltaCol[_deltaIdx]])))) {
        _deltaIdx += 1;
    }

    if(_deltaIdx >= NUM_DELTAS) {
        return nil;
    }

    // Yes, I know that technically rows are y and cols are x. This just makes it less confusing for
    // me.
    let point = [Point2 pointWithCoordinates:_row + deltaRow[_deltaIdx]
                                           y:_col + deltaCol[_deltaIdx]];
    _deltaIdx += 1;
    return point;
}
@end

@implementation HeightMap
- (NeighborEnumerator *)neighbors:(size_t)row col:(size_t)col anti:(BOOL)anti {
    return [[NeighborEnumerator alloc] initWithMapAndPoint:self row:row col:col anti:anti];
}

@end
