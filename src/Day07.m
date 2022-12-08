#import "Day07.h"

static InputLine *parseLine(OFString *line) {
    let components = [line componentsSeparatedByString:@" "];

    if([line hasPrefix:@"$ cd"]) {
        return [[CDCommand alloc] initWithDir:components[2]];
    } else if([line isEqual:@"$ ls"]) {
        return [LSCommand new];
    } else if([line hasPrefix:@"dir"]) {
        return [[DirEntry alloc] initWithName:components[1]];
    } else { // file
        return [[FileEntry alloc] initWithNameAndSize:components[1]
                                                 size:components[0].longLongValue];
    }
}

@implementation FSNode
@dynamic name;
@dynamic size;
@end

@implementation Dir {
    unsigned long long _cachedSize;
    BOOL _didCalculateSize;
}
@synthesize name = _name;
@synthesize contents = _contents;

- (instancetype)initWithName:(OFString *)name {
    self = [super init];

    _name = name;
    _cachedSize = 0;
    _didCalculateSize = NO;
    _contents = [OFMutableDictionary dictionary];

    return self;
}

// NOTE: Only call this after the directory has been populated, otherwise the cached value will
// stick.
- (unsigned long long)size {
    if(!_didCalculateSize) {
        // _cached_size is already 0
        for(FSNode *node in [_contents objectEnumerator]) {
            _cachedSize += node.size;
        }

        _didCalculateSize = YES;
    }
    return _cachedSize;
}

- (void)performOnSubdirs:(void (^)(Dir *))block {
    block(self);

    for(FSNode *node in [self.contents objectEnumerator]) {
        if([node isMemberOfClass:[Dir class]]) {
            Dir *dir = (Dir *)node;
            [dir performOnSubdirs:block];
        }
    }
}
@end

@implementation File
@synthesize name = _name;
@synthesize size = _size;

- (instancetype)initWithNameAndSize:(OFString *)name size:(unsigned long long)size {
    self = [super init];

    _name = name;
    _size = size;

    return self;
}
@end

@implementation Day07 {
    Dir *_root;
}
- (instancetype)initWithStream:(OFStream *)stream {
    self = [super init];

    Dir *root = [[Dir alloc] initWithName:@"/"];
    OFMutableArray<Dir *> *stack = [OFMutableArray arrayWithObject:root];

    OFString *line;
    while((line = [stream readLine])) {
        let parsed = parseLine(line);

        if([parsed isMemberOfClass:[CDCommand class]]) {
            CDCommand *cmd = (CDCommand *)parsed;

            if([cmd.dir isEqual:@".."]) {
                if(stack.count == 1) {
                    @throw @"Attempted to pop the root directory!";
                }

                [stack removeLastObject];
            } else if([cmd.dir isEqual:@"/"]) {
                if(stack.count > 1) {
                    OFRange allButFirst = {.location = 1, .length = stack.count - 1};
                    [stack removeObjectsInRange:allButFirst];
                }
            } else {
                FSNode *node = stack.lastObject.contents[cmd.dir];
                if(![node isMemberOfClass:[Dir class]]) {
                    @throw @"Attempted to cd into something that isn't a directory!";
                }

                Dir *dir = (Dir *)node;
                [stack addObject:dir];
            }
        } else if([parsed isMemberOfClass:[LSCommand class]]) {
            // do nothing? idk
        } else if([parsed isMemberOfClass:[DirEntry class]]) {
            DirEntry *entry = (DirEntry *)parsed;

            stack.lastObject.contents[entry.name] = [[Dir alloc] initWithName:entry.name];
        } else if([parsed isMemberOfClass:[FileEntry class]]) {
            FileEntry *entry = (FileEntry *)parsed;

            stack.lastObject.contents[entry.name] = [[File alloc] initWithNameAndSize:entry.name
                                                                                 size:entry.size];
        } else {
            OF_UNREACHABLE
        }
    }

    [root size]; // calculate all sizes

    _root = root;

    return self;
}

- (OFObject *)runPart1 {
    __block unsigned long long sum = 0;
    [_root performOnSubdirs:^(Dir *dir) {
        if(dir.size <= 100000) {
            sum += dir.size;
        }
    }];

    return @(sum);
}

- (OFObject *)runPart2 {
    const unsigned long long TOTAL = 70000000;
    const unsigned long long REQUIRED_FREE = 30000000;

    let currentFree = TOTAL - _root.size;
    __block let minSize = REQUIRED_FREE - currentFree;

    __block unsigned long long currentMin = (unsigned long long)-1;
    [_root performOnSubdirs:^(Dir *dir) {
        let size = dir.size;
        if(size >= minSize && size < currentMin) {
            currentMin = size;
        }
    }];

    return @(currentMin);
}
@end

@implementation InputLine
@end

@implementation LSCommand
@end

@implementation CDCommand
- (instancetype)initWithDir:(OFString *)dir {
    self = [super init];

    _dir = dir;

    return self;
}
@end

@implementation DirEntry
- (instancetype)initWithName:(OFString *)name {
    self = [super init];

    _name = name;

    return self;
}
@end

@implementation FileEntry
- (instancetype)initWithNameAndSize:(OFString *)name size:(unsigned long long)size {
    self = [super init];

    _name = name;
    _size = size;

    return self;
}
@end
