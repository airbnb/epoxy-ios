// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
      ]),
    .target(name: "EpoxyCore"),
    .target(name: "EpoxyCollectionView", dependencies: ["EpoxyCore"]),
    .target(name: "EpoxyBars", dependencies: ["EpoxyCore"]),
    .target(name: "EpoxyNavigationController", dependencies: ["EpoxyCore"]),
    .target(name: "EpoxyPresentations", dependencies: ["EpoxyCore"]),
    .target(name: "EpoxyLayoutGroups", dependencies: ["EpoxyCore"]),
    .testTarget(name: "EpoxyTests", dependencies: ["Epoxy", "Quick", "Nimble"]),
    .testTarget(name: "PerformanceTests", dependencies: ["EpoxyCore"]),
  ])

#if swift(>=5.6)
// Add the Airbnb Swift formatting plugin if possible
package.dependencies.append(.package(url: "https://github.com/airbnb/swift", .branch("cal--epoxy-integration-wip-branch")))
#endif
