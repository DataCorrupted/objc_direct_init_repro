#import "Foo.h"
@implementation Foo
- (instancetype)initWithSeed:(NSInteger)seed { return [super init]; }
- (instancetype)initWithName:(NSString *)name { return [self initWithSeed:(NSInteger)name.length]; }
+ (instancetype)makeWithSeed:(NSInteger)seed { return [[self alloc] initWithSeed:seed]; }
@end
Foo *ObjCMakeWithClass(Class cls) { return [(Foo *)[cls alloc] initWithSeed:1]; }
