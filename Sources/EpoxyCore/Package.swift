// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EpoxyCore",
  platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15)],
  products: [
    .library(name: "EpoxyCore", targets: ["EpoxyCore"]),
  ],
  targets: [
    .target(name: "EpoxyCore", path: ""),
  ])
