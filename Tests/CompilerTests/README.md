# Wrapper isolation compiler regression

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
