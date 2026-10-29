# An objc_direct designated initializer skips a Swift subclass's stored properties

The Objective-C class `Foo` marks its designated initializer `-initWithSeed:`
with `__attribute__((objc_direct))`. A direct method has no method-list entry,
so when that initializer runs on an instance of the Swift subclass `Sub`, only
`Foo`'s implementation runs. `Sub`'s stored-property initialization is skipped,
and `Sub.helper`, a non-optional `NSObject`, reads as nil. That's undefined
behavior, and nothing diagnoses it at compile time or at run time.

## Build and run

Needs Xcode's command-line tools. Tested with Xcode 27.1 (Apple Swift 6.4,
Apple clang 21) and the GNU make 3.81 that ships with macOS.

```
make run
```

Output:

```
Sub(seed:)            Sub helper set: true
Sub(name:)            Sub helper set: false
Sub.make(withSeed:)   Sub helper set: false
Sub.make()            Sub helper set: false
ObjC [[cls alloc] …]  Sub helper set: false
```

`helper set` reports whether `Sub.helper` is non-nil:

- `Sub(seed:)`: `Sub`'s synthesized `init(seed:)` override runs first.
- `Sub(name:)`: the inherited Objective-C convenience initializer
  `-initWithName:` calls `[self initWithSeed:]`.
- `Sub.make(withSeed:)`: the Objective-C factory `+makeWithSeed:` calls
  `[[self alloc] initWithSeed:]`.
- `Sub.make()`: a Swift factory returning `Self` calls `self.init(seed:)`.
- `ObjCMakeWithClass(Sub.self)`: Objective-C calls
  `[(Foo *)[cls alloc] initWithSeed:1]` on a `Class` value.

`make control` builds the same program with `objc_direct` defined away, and all
five lines print `true`.

Set `CLANG` or `SWIFTC` to use another toolchain, for example
`make run CLANG=/path/to/clang`.
