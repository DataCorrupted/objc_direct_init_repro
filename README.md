# An objc_direct designated initializer skips a Swift subclass's stored properties

The Objective-C class `Foo` marks its designated initializer `-initWithSeed:`
with `__attribute__((objc_direct))`. A direct method has no method-list entry,
so when that initializer runs on an instance of the Swift subclass `Sub`, only
`Foo`'s implementation runs. `Sub`'s stored-property initialization is skipped,
and `Sub.helper`, a non-optional `NSObject`, reads as nil. That's undefined
behavior, and stock toolchains don't diagnose it, at compile time or at run
time. A proposed clang warning, `-Wobjc-direct-init-subclass`, catches the
Objective-C route below.

## Build and run

Needs Xcode's command-line tools. Tested with Xcode 27.1 (Apple Swift 6.4,
Apple clang 21) and the GNU make 3.81 that ships with macOS.

```
make run
```

Set `CLANG` or `SWIFTC` to use another toolchain, for example
`make run CLANG=/path/to/clang`.

Output:

```
Sub(seed:)            Sub helper set: true
Sub(name:)            Sub helper set: false
Sub.make(withSeed:)   Sub helper set: false
Sub.make()            Sub helper set: false
ObjC [[cls alloc] …]  Sub helper set: false
ObjC [[Sub alloc] …]  Sub helper set: false
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
- `ObjCMakeSub()`: Objective-C in `Client.m` calls
  `[[Sub alloc] initWithSeed:1]`, with a receiver whose static type is `Sub *`.

`make control` builds the same program with `objc_direct` defined away, and all
six lines print `true`.

## -Wobjc-direct-init-subclass

The warning isn't in a released clang yet. To see it, build with a clang that
has it, cleaning first so the objects are rebuilt with it:

```
make clean run CLANG=/path/to/llvm-project/build/bin/clang
```

It flags the one route clang can see, the call in `Client.m`:

```
Client.m:6:46: warning: direct initializer 'initWithSeed:' of 'Foo' leaves subclass 'Sub' partially initialized [-Wobjc-direct-init-subclass]
```

The other routes stay silent. Swift call sites never reach clang. `Foo`'s own
convenience initializer and factory send the message to a `Foo *`, and
`ObjCMakeWithClass` casts to `Foo *`.

`Client.m` declares `Sub` by hand, and `main.swift` gives it the Objective-C
name `Sub`. Swift's generated header can't be used: it redeclares
`-initWithSeed:` on `Sub`, and clang rejects that because the method is direct.
