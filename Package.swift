// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// SPIKE: Broadly isolate all Epoxy modules to the main actor by default, to explore whether we can
// satisfy the Swift Concurrency compiler's guarantees with `@MainActor`. See branch
// `agc--mainactor-isolation-spike`.
let mainActorIsolation: [SwiftSetting] = [
  .defaultIsolation(MainActor.self),
  // With default main-actor isolation, a `@MainActor` type's protocol conformances must also be
  // main-actor isolated. This upcoming feature infers that automatically so we don't have to
  // annotate every `: @MainActor SomeProtocol` conformance by hand.
  .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
  name: "Epoxy",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "Epoxy", targets: ["Epoxy"]),
    .library(name: "EpoxyCore", targets: ["EpoxyCore"]),
    .library(name: "EpoxyCollectionView", targets: ["EpoxyCollectionView"]),
    .library(name: "EpoxyBars", targets: ["EpoxyBars"]),
    .library(name: "EpoxyNavigationController", targets: ["EpoxyNavigationController"]),
    .library(name: "EpoxyPresentations", targets: ["EpoxyPresentations"]),
    .library(name: "EpoxyLayoutGroups", targets: ["EpoxyLayoutGroups"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.0.0")),
  ],
  targets: [
    .target(
      name: "Epoxy",
      dependencies: [
        "EpoxyCore",
        "EpoxyCollectionView",
        "EpoxyBars",
        "EpoxyNavigationController",
        "EpoxyPresentations",
        "EpoxyLayoutGroups",
      ],
      swiftSettings: mainActorIsolation),
    .target(name: "EpoxyCore", swiftSettings: mainActorIsolation),
    .target(name: "EpoxyCollectionView", dependencies: ["EpoxyCore"], swiftSettings: mainActorIsolation),
    .target(name: "EpoxyBars", dependencies: ["EpoxyCore"], swiftSettings: mainActorIsolation),
    .target(name: "EpoxyNavigationController", dependencies: ["EpoxyCore"], swiftSettings: mainActorIsolation),
    .target(name: "EpoxyPresentations", dependencies: ["EpoxyCore"], swiftSettings: mainActorIsolation),
    .target(name: "EpoxyLayoutGroups", dependencies: ["EpoxyCore"], swiftSettings: mainActorIsolation),
    // The test targets keep the default (nonisolated) isolation and stay on the Swift 5 language
    // mode, for two reasons:
    //   1. `QuickSpec`'s `spec()` / `init()` are nonisolated, so a target-wide `@MainActor` default
    //      would conflict with those overrides.
    //   2. Quick specs share non-`Sendable` state (e.g. `GroupItem`, model storage) through captured
    //      `var`s across the bridged `@MainActor` closures. That state never leaves the main thread,
    //      but Swift 6's region-based `sending` analysis can't prove it. Region isolation is only
    //      enforced in the Swift 6 language mode, so Swift 5 mode keeps the tests compiling without
    //      resorting to `nonisolated(unsafe)`.
    // Actor-isolation (the guarantee this spike validates) is still enforced: specs that drive the
    // now-main-actor API conform to the `MainActorSpec` bridge, and test-only helpers that model
    // main-actor library protocols are annotated `@MainActor`.
    .testTarget(
      name: "EpoxyTests",
      dependencies: ["Epoxy", "Quick", "Nimble"],
      swiftSettings: [.swiftLanguageMode(.v5)]),
    .testTarget(
      name: "PerformanceTests",
      dependencies: ["EpoxyCore"],
      swiftSettings: [.swiftLanguageMode(.v5)]),
  ])

#if swift(>=5.6)
// Add the Airbnb Swift formatting plugin if possible
package.dependencies.append(.package(url: "https://github.com/airbnb/swift", .upToNextMajor(from: "1.0.1")))
#endif
