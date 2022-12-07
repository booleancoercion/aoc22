#import "Day.h"

OF_ASSUME_NONNULL_BEGIN

@interface Day07 : Day
- init OF_UNAVAILABLE;
@end

@interface InputLine : OFObject
@end

@interface CDCommand : InputLine
@property(readonly, nonatomic) OFString *dir;

- (instancetype)initWithDir:(OFString *)dir;
- init OF_UNAVAILABLE;
@end

@interface LSCommand : InputLine
@end

@interface DirEntry : InputLine
@property(readonly, nonatomic) OFString *name;

- (instancetype)initWithName:(OFString *)name;
- init OF_UNAVAILABLE;
@end

@interface FileEntry : InputLine
@property(readonly, nonatomic) OFString *name;
@property(readonly, nonatomic) unsigned long long size;

- (instancetype)initWithNameAndSize:(OFString *)name size:(unsigned long long)size;
- init OF_UNAVAILABLE;
@end

/////////////////////////

@interface FSNode : OFObject
@property(readonly, nonatomic) OFString *name;
@property(readonly, nonatomic) unsigned long long size;
@end

@interface Dir : FSNode
@property(readonly, nonatomic) OFMutableDictionary<OFString *, FSNode *> *contents;

- (instancetype)initWithName:(OFString *)name;
- init OF_UNAVAILABLE;

- (void)performOnSubdirs:(void (^)(Dir *))block;
@end

@interface File : FSNode
- (instancetype)initWithNameAndSize:(OFString *)name size:(unsigned long long)size;
- init OF_UNAVAILABLE;
@end

OF_ASSUME_NONNULL_END
