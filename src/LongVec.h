#import <ObjFW/ObjFW.h>

typedef long long LongVecItem;

OF_ASSUME_NONNULL_BEGIN

@interface LongVec : OFObject <OFMutableCopying>
@property(readonly, nonatomic) size_t length;

- (LongVecItem)getItem:(size_t)idx;
- (void)setItem:(size_t)idx value:(LongVecItem)value;
- (void)pushItem:(LongVecItem)value;
- (LongVecItem)popItem;
- (void)clearAllItems;
@end

OF_ASSUME_NONNULL_END
