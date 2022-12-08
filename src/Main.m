#import "Day.h"
#import <ObjFW/ObjFW.h>

@interface Main : OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Main)

// Returns an array of all registered classes that derive from Day (including Day itself).
// The returned array is sorted alphabetically by class name.
static OFArray<Class> *getDays(void) {
    unsigned int count = objc_getClassList(NULL, 0);

    Class *buffer = (Class *)malloc(count * sizeof(*buffer));
    objc_getClassList(buffer, count);
    OFArray *days = [OFArray arrayWithObjects:buffer count:count];
    free(buffer);

    days = [days filteredArrayUsingBlock:^(Class obj, size_t _) {
        return [obj isSubclassOfClass:[Day class]];
    }];

    OFComparisonResult (^classNameComparator)(Class, Class) = ^(Class cls1, Class cls2) {
        return [[cls1 className] compare:[cls2 className]];
    };

    return [days sortedArrayUsingComparator:classNameComparator options:0];
}

@implementation Main
- (void)applicationDidFinishLaunching:(OFNotification *)notification {
    OFArray<Class> *days = getDays();

    int daynum;

    OFArray<OFString *> *args = [OFApplication arguments];
    if([args count] == 0) {
        daynum = [days count] - 1;
    } else if([args count] == 1) {
        @try {
            daynum = args[0].longLongValue;
        } @catch(id error) {
            [OFStdErr
                writeLine:@"Invalid day number provided. Please use a (reasonably small) number."];
            [OFApplication terminateWithStatus:1];
        }

        if(daynum >= [days count] || daynum < 1) {
            [OFStdErr
                writeFormat:@"Invalid day number provided. Please use a number between 1 and %d.\n",
                            [days count] - 1];
            [OFApplication terminateWithStatus:1];
        }
    } else {
        [OFStdErr writeLine:@"Too many arguments!"];
        [OFApplication terminateWithStatus:2];
        OF_UNREACHABLE // to silence warning about daynum being uninit
    }

    [OFStdOut writeFormat:@"Executing day %d...\n", daynum];

    Class dayClass = days[daynum];

    OFString *filePath =
        [OFString stringWithFormat:@"input/%@.txt", [[dayClass className] lowercaseString]];
    OFFile *file;
    @try {
        file = [OFFile fileWithPath:filePath mode:@"r"];
    } @catch(id error) {
        [OFStdErr writeLine:@"Unable to open input file."];
        [OFApplication terminateWithStatus:3];
    }

    Day *day;
    @try {
        day = [dayClass dayWithStream:file];
    } @catch(id error) {
        [OFStdErr writeLine:@"Unable to create class instance."];
        [OFApplication terminateWithStatus:4];
    }

    // clang-format off
    @try {
        [OFStdOut writeFormat:@"Part 1 output: %@\n", [day runPart1]];
    } @catch(id error) {
        if ([error isMemberOfClass:[OFNotImplementedException class]]) {
            [OFStdErr writeLine:@"Part 1 is not implemented!"];
            [OFApplication terminateWithStatus:5];
        } else {
            [OFStdErr writeLine:@"Part 1 threw an exception:"];
            @throw error;
        }
    }

    @try {
        [OFStdOut writeFormat:@"Part 2 output: %@\n", [day runPart2]];
    } @catch(id error) {
        if ([error isMemberOfClass:[OFNotImplementedException class]]) {
            [OFStdErr writeLine:@"Part 2 is not implemented!"];
            [OFApplication terminateWithStatus:5];
        } else {
            [OFStdErr writeLine:@"Part 2 threw an exception:"];
            @throw error;
        }
    }
    // clang-format on

    [OFApplication terminate];
}
@end
