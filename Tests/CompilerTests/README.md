# Layout isolation compiler contracts

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
