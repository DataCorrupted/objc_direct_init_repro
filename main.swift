import Foundation

setbuf(stdout, nil)
extension Foo {
  class func make() -> Self { self.init(seed: 1) } // Swift factory returning Self
}
class Sub: Foo { var helper = NSObject() }
func report(_ label: String, _ s: Foo) {
  // swiftlint:disable:next force_cast
  print(label, type(of: s), "helper set:", unsafeBitCast((s as! Sub).helper, to: Int.self) != 0)
}
report("Sub(seed:)           ", Sub(seed: 1)) // Sub's synthesized override runs first
report("Sub(name:)           ", Sub(name: "abcd")) // inherited ObjC convenience init
report("Sub.make(withSeed:)  ", Sub.make(withSeed: 4)) // ObjC factory
report("Sub.make()           ", Sub.make()) // Swift factory returning Self
report("ObjC [[cls alloc] …] ", ObjCMakeWithClass(Sub.self))
