# Behavior isolation compiler contracts

The `test-compiler` CI job builds the simulator modules and runs these contracts on every pull
request to `master` and every push to `master`, using Xcode 26.0.1 (Swift 6.2).

To run locally with Swift 6.2 or newer and an iOS Simulator SDK:

```sh
xcodebuild build -scheme Epoxy -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/epoxy-behaviors
bash Tests/CompilerTests/check-set-behaviors.sh /tmp/epoxy-behaviors/Build/Products/Debug-iphonesimulator
```

The fixture checks that model construction and callback storage remain nonisolated, callbacks can
configure UIKit directly, and synchronous off-actor invocation is rejected. It enables complete
concurrency and `InferIsolatedConformances` and treats warnings as errors. Runtime chaining,
copying, and merging are covered by `SetBehaviorsTests` in the unit test target.

Group construction is checked on the main actor because the existing `Constrainable` conformance
has a separate inferred-isolation issue. The consumer probe targets iOS 15 to match current Xcode
build products; the package deployment minimum remains iOS 13.

The consumer contracts run in both Swift 5 and Swift 6 language modes.
