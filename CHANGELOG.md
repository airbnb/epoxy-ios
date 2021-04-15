# Changelog
All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/airbnb/epoxy-ios/compare/0.2.0...HEAD)

### Added
- Added support for `Array` and `Optional` expressions to model result builders
- Added support for `Optional` expressions to `PresentationModel` result builders
- Made `AnyItemModel` conform to `DidChangeStateProviding`, `DidChangeStateProviding` and `SetBehaviorsProviding`.
- Made `AnySupplementaryItemModel` conform to `DidChangeStateProviding`, and `SetBehaviorsProviding`.
- Adds a `keyboardContentInsetAdjustment` property to `UIScrollView` with the amount that the that its `contentInset.bottom` has been adjusted to accommodate for the keyboard by a `KeyboardPositionWatcher`.
- Made `ItemSelectionStyle` conform to `Hashable`

### Fixed
- Bar installers gracefully handle redundant calls to install/uninstall
- Collection Views more gracefully handle styleID mutations after registration

## [0.2.0](https://github.com/airbnb/epoxy-ios/compare/0.1.0...0.2.0) - 2021-03-16

### Added
- Added result builders for `SectionModel`, `ItemModel`, `BarModel`, `PresentationModel`, and
  `NavigationModel`
- Added initializers and methods to `CollectionViewController` that take an array of `ItemModel`s
  and transparently wrap them in a `SectionModel` for consumers.

### Changed
- Updated public let properties of public structs with memberwise initializers to be public var
- `BarStackView` now handles selection of bar models and can be used as an `EpoxyableView`
- The cases of `BarStackView.ZOrder` have been renamed to be more semantically accurate
- Enables `CollectionView` prefetching by default, as the issues preventing it from being enabled by
  default are now resolved in recent iOS versions
- Support animated moves in `BarStackView`
- Fixed ordering when inserting and removing bar models
- Crossfade between bars of the same view type with different style IDs in `BarStackView`

## [0.1.0](https://github.com/airbnb/epoxy-ios/compare/171f63da...0.1.0) - 2021-02-01

### Added
- Initial release of Epoxy
