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
    // NOTE: The test targets keep the default (nonisolated) isolation. Specs that exercise the (now
    // main-actor) library API bridge to the main actor via the `MainActorSpec` protocol, whose DSL
    // takes `@MainActor` closures. Isolating the whole target instead would conflict with
    // `QuickSpec`'s nonisolated `spec()` / `init()` overrides.
    .testTarget(name: "EpoxyTests", dependencies: ["Epoxy", "Quick", "Nimble"]),
    .testTarget(name: "PerformanceTests", dependencies: ["EpoxyCore"]),
  ])

#if swift(>=5.6)
// Add the Airbnb Swift formatting plugin if possible
package.dependencies.append(.package(url: "https://github.com/airbnb/swift", .upToNextMajor(from: "1.0.1")))
#endif
