# Isolation compiler contracts

## Wrapper isolation

The `test-compiler` CI job runs on every pull request to `master` and every push to `master`,
using Xcode 26.0.1 (Swift 6.2). To run locally, use
`bash Tests/CompilerTests/check-item-wrapper.sh` with Swift 6.2 or newer and an iOS Simulator SDK.
The script compiles the actual wrapper sources in both Swift 5 and Swift 6 language modes under
complete concurrency with `InferIsolatedConformances`, treating warnings as errors.

`ItemWrapperView.swift` reproduces an actor-isolated protocol refining an intermediate wrapper
protocol. In Swift 5 mode, before the explicit protocol annotations, `EmbeddedView` produces a
diagnostic that its `FocusableEmbeddedItemView` conformance depends on an actor-isolated
`EmbeddedItemView` conformance.
Inheriting the UIKit superclass constraint alone does not express that protocol isolation.
Swift 6 mode also checks compatibility, but does not reproduce this diagnostic on Swift 6.4.

## Behavior isolation

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
