#import "misc.h"

int abs(int x) {
    if(x >= 0) {
        return x;
    } else {
        return -x;
    }
}

int max(int a, int b) {
    if(a > b) {
        return a;
    } else {
        return b;
    }
}
