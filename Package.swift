// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Epoxy",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "Epoxy", targets: ["Epoxy"]),
    .library(name: "EpoxyCore", targets: ["EpoxyCore"]),
  ],
  targets: [
    .target(name: "Epoxy", dependencies: ["EpoxyCore", "EpoxyCollectionView"]),
    .target(name: "EpoxyCore"),
    .target(name: "EpoxyCollectionView", dependencies: ["EpoxyCore"]),
    .testTarget(name: "EpoxyTests", dependencies: ["Epoxy"]),
  ]
)
