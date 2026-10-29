#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface Foo : NSObject
- (instancetype)initWithSeed:(NSInteger)seed __attribute__((objc_direct)) NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name;   // convenience: [self initWithSeed:]
+ (instancetype)makeWithSeed:(NSInteger)seed;    // factory: [[self alloc] initWithSeed:]
@end
Foo *ObjCMakeWithClass(Class cls);                // [(Foo *)[cls alloc] initWithSeed:1]
Foo *ObjCMakeSub(void);                           // Client.m: [[Sub alloc] initWithSeed:1]
NS_ASSUME_NONNULL_END
