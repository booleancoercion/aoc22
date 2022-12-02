#import <ObjFW/ObjFW.h>

@interface Main : OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Main)

@implementation Main
- (void)applicationDidFinishLaunching:(OFNotification *)notification {
    [OFStdOut writeLine:@"Hello, World!"];

    [OFApplication terminate];
}
@end
