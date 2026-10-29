#import "Foo.h"
// Swift's generated header redeclares -initWithSeed: on Sub, which clang rejects
// because the method is direct, so declare the Swift class by hand.
@interface Sub : Foo
@end
Foo *ObjCMakeSub(void) { return [[Sub alloc] initWithSeed:1]; }
