#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface IntMatrix : OFObject
@property(readonly, nonatomic) size_t width;
@property(readonly, nonatomic) size_t height;

+ (instancetype)matrixWithWidthHeightValue:(size_t)width height:(size_t)height value:(int)value;
+ (instancetype)matrixWithStream:(OFStream *)stream;
+ (instancetype)matrixWithStream:(OFStream *)stream offsetChar:(char)offsetChar;

// zero-initializes the array with the given width and height
- (instancetype)initWithWidthHeightValue:(size_t)width height:(size_t)height value:(int)value;

- (instancetype)initWithStream:(OFStream *)stream;
- (instancetype)initWithStream:(OFStream *)stream offsetChar:(char)offsetChar;
- init OF_UNAVAILABLE;

- (void)set:(size_t)row col:(size_t)col value:(int)value;
- (int)get:(size_t)row col:(size_t)col;

- (void)setRaw:(size_t)idx value:(int)value;
- (int)getRaw:(size_t)idx;
@end

OF_ASSUME_NONNULL_END
