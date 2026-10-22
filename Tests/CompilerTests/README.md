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

## Layout isolation

The `test-compiler` CI job builds the layout simulator modules with isolation inference and runs
these contracts on every pull request to `master` and every push to `master`, using Xcode 26.0.1
(Swift 6.2).

To run locally with Swift 6.2 or newer and an iOS Simulator SDK:

```sh
xcodebuild build -scheme EpoxyLayoutGroups -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/epoxy-layout SWIFT_STRICT_CONCURRENCY=complete OTHER_SWIFT_FLAGS='$(inherited) -enable-upcoming-feature InferIsolatedConformances'
bash Tests/CompilerTests/check-constrainable.sh /tmp/epoxy-layout/Build/Products/Debug-iphonesimulator
```

The fixture checks nonisolated generic and subclass model construction, concrete-to-existential
conversions, identity and equality (including spacer style equality and container diffing).
Layout is accepted on the main actor; off-actor installation, frame and anchor access must fail.
Warnings are treated as errors in the consumer fixture. The probe targets iOS 15 because recent
Xcode versions raise the effective build minimum; the package still declares iOS 13.

The conformances explicitly opt out of inferred isolation on compilers supporting that syntax
(Swift 6.2+). Older compilers use ordinary conformances; tools and deployment minimums are unchanged.
This does not isolate the entire `Group` protocol or change value alignment equality/hashing.

The consumer contracts run in both Swift 5 and Swift 6 language modes.

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

The behavior fixture checks group construction on the main actor; nonisolated group construction
is covered by the layout fixture above. The consumer probe targets iOS 15 to match current Xcode
build products; the package deployment minimum remains iOS 13.

The consumer contracts run in both Swift 5 and Swift 6 language modes.
