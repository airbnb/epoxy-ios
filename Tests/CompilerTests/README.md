# Wrapper isolation compiler regression

Run `bash Tests/CompilerTests/check-item-wrapper.sh` with Swift 6.2 or newer and an iOS Simulator SDK.
The script compiles the actual wrapper sources under complete concurrency with
`InferIsolatedConformances`, treating warnings as errors.

`ItemWrapperView.swift` reproduces an actor-isolated protocol refining an intermediate wrapper
protocol. Before the explicit protocol annotations, `EmbeddedView` produces a diagnostic that its
`FocusableEmbeddedItemView` conformance depends on an actor-isolated `EmbeddedItemView` conformance.
Inheriting the UIKit superclass constraint alone does not express that protocol isolation.
