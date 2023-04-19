# Changelog
All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/airbnb/epoxy-ios/compare/0.9.0...HEAD)

### Changed
- Dropped support for Swift 5.4.
- Added `UIScrollView.keyboardAdjustsBottomBarOffset` escape hatch to disable bottom bar keyboard
  avoidance for cases where the keyboard is avoided at a higher level (e.g. a
  `UIPresentationController` subclass).
- Added `configuredView(traitCollection:)` API to `SupplementaryItemModeling`.
- Changed `NavigationModel`'s `remove()` method access modifier to public (previously internal).
- Changed `NavigationModel`'s `handleDidRemove()` method access modifier to public (previously 
  internal).

### Fixed
- For top and bottom bars, if any view in the hierarchy has a scale transform, wait to apply the 
  insets as they may be incorrect.
- Pass initial size to embedded view from `CollectionViewCell`/`CollectionViewReusableView` to 
  better load embedded SwiftUI views.
- Guard against a UIKit crash caused by attempting to scroll to an item that no longer exists.

## [0.9.0](https://github.com/airbnb/epoxy-ios/compare/0.8.0...0.9.0) - 2022-10-25

### Changed
- Remove all of the `EpoxyableView` flavors of `MeasuringUIViewRepresentable` in favor of a
  single shared `SwiftUIUIView` that supports a generic `Storage`, which has the added benefit of
  fixing some Xcode preview crashes.

### Fixed
- Improved double layout pass heuristics for views that have intrinsic size dimensions below 1 or
  for views that have double layout pass subviews that aren't horizontally constrained to the edges.
- Fixed HGroupItem and VGroupItem not respecting some properties of the style that is passed in.
- Improved sizing of intrinsically sized UIViews in SwiftUI with no intrinsic metric size proposals.
- Add extra logic for mitigating proposed sizes that match previous intrinsic size for hosted
  UIViews in SwiftUI.

## [0.8.0](https://github.com/airbnb/epoxy-ios/compare/0.7.0...0.8.0) - 2022-07-28

### Added
- Added `SwiftUIMeasurementContainer` for calculating the ideal height of a `UIView` for wrapping
  for SwiftUI usage.
- Added `MeasuringUIViewRepresentable` as a convenience API for measuring a `UIView` within a
  `UIViewRepresentable` using an enclosing `SwiftUIMeasurementContainer`.
- Added a method to `CollectionViewReorderingDelegate` to check the reordering destination is
  expected.
- Added the ability to pass a `CollectionViewConfiguration` to the `CollectionViewController`
  initializers.
- Added additional sizing behaviors to `SwiftUIMeasurementContainer` for sizing `UIView`s hosted in
  a  SwiftUI `View`.
- Added a static `swiftUIView(…)` method to `UIView` for hosting UIKit views that aren't
  `EpoxyableView`s while still leveraging the layout helpers.
- Added support for calling `configure { _ in }` on the SwiftUI `View` resulting from a
  `swiftUIView(…)` invocation to perform additional configuration of the `UIView` instance.
- Added `LayoutGroupUpdateAnimation` for customizing `Group` animated updates.
- Added support for `WillDisplay` callbacks to be added to type-erased `AnyBarModel` types.

### Fixed
- Fixed sizing of reused `EpoxySwiftUIHostingController`s on iOS 15.2+.
- Fixed crash in `ScrollToItemHelper` caused by `preferredFrameRateRanges` on devices running iOS
  15.0 (this issue is not present in devices on 15.1+)
- Fixed an ambiguous layout issue when using `LayoutSpacer` without a `fixedWidth` or `fixedHeight`.
- Gracefully support cases where a `SwiftUIMeasurementContainer` with an `intrinsicSize`
  `SwiftUIMeasurementContainerStrategy` has an intrinsic size that exceeds the proposed size by
  compressing rather than overflowing, which could result in broken layouts.
- Fixed intrinsic size invalidation triggered by a SwiftUI view from within a collection view
  cell by invalidating the enclosing collection view layout.
- Fixed an issue where `EpoxyLogger.shared.assertionFailure` and `EpoxyLogger.shared.assert` would
  unexpectedly crash in release builds.

### Changed
- Updated name of `Spacer` to `LayoutSpacer` to avoid name conflict with SwiftUI's `Spacer`
- Updated to have Swift 5.4 as the minimum supported Swift version (previously Swift 5.3).
- Updated `HGroupView` and `VGroupView` to have `insetsLayoutMarginsFromSafeArea = false` by default
- Gated an old autoresizing-mask-related bug workaround to only run on iOS versions 13 and below
- The `swiftUIView(…)` methods now default to an automatic sizing behavior that makes a best effort
  at sizing the view based on heuristics, rather than defaulting to intrinsic height and proposed
  width.

## [0.7.0](https://github.com/airbnb/epoxy-ios/compare/0.6.0...0.7.0) - 2021-12-09

### Added
- Added a weak reference from `TopBarContainer` / `BottomBarContainer` to their parent bar installer
- Added a `BarInstallerConfiguration` type to allow both global and per-instance configuration of
  bar installers.
- Added an `applyBars` closure to `BarInstallerConfiguration` to allow consumers to configure _when_
  bars are applied to the underlying `BarContainer` by a bar installer, e.g. to defer bar model
  updates that might conflict with an in-flight shared element transition.
- Support for hitting 120 FPS on iPhone ProMotion displays when programmatically scrolling to an
  item in a collection view.
- Added `itemModel(…)`, `barModel(…)` methods to host a SwiftUI `View` within an Epoxy container and
  the `swiftUIView(…)` method to host an `EpoxyableView` within a SwiftUI `View`
- Added a SwiftUI environment value for requesting size invalidation of the containing Epoxy
  collection view cell.

### Fixed
- Fixes an issue that could cause `CollectionView` scroll animation frames to have an incorrect
  content offset when paired with a non-zero `adjustedContentInset`.
- Fixes an issue that could cause `VGroupView` and `HGroupView` to grow too tall when nested in
  containers that give them a larger height than their natural height.
- Fixes a bug in the `KeyboardPositionWatcher` that would consider an even slightly offscreen view
  as having a keyboard overlap when the keyboard is dismissed, resulting in incorrect keyboard
  offsets.
- Fixes an issue when mutating state synchronously does not pick up the current SwiftUI transaction.
- Fixes a bug where the `avoidsKeyboard` parameter would be disregarded in a `BottomBarInstaller`
  initializer.

### Changed
- Removed the default bar installer behavior where bar model updates were deferred while a view
  controller transition is in progress.

## [0.6.0](https://github.com/airbnb/epoxy-ios/compare/0.5.0...0.6.0) - 2021-08-31

### Added
- Added an `insetMargins` property to `TopBarContainer` and `BottomBarContainer` that configures
  whether or not the container sets layout margins derived from the `safeAreaInsets` of its
  `viewController`.

### Fixed
- Fixed incorrect assertion logging when accessing an item with an invalid index path.
- Mitigated a `EXC_BAD_ACCESS` crash that caused by a bad `nonnull` bridge in `CollectionViewCell`.
- Fixed an issue where styles were not being used in the `diffIdentifier` calculation of
  `GroupItems`.

### Changed
- The `SectionModel` initializer now requires a `dataID` to make it harder to have sections with
  duplicate identity that causes a runtime warning and potentially unexpected diffing behavior.

## [0.5.0](https://github.com/airbnb/epoxy-ios/compare/0.4.0...0.5.0) - 2021-06-23

### Added
- Added an `UpdateStrategy` to `CollectionView` to allow specifying that it should update using non-
  animated `performBatchUpdates(…)`, which can be more performant and behave more predictably than
  `reloadData()`.
- Added `reflowsForAccessibilityTypeSizes` and `forceVerticalAccessibilityLayout` properties to
  `HGroup.Style`.

### Fixed
- Improved `CollectionView` logic for deciding when to `reloadData(…)` over `performBatchUpdates(…)`
  in specific scenarios.
- Fixed an issue where the `accessibilityAlignment` property of `HGroup` was not being respected.
- Fixed an issue where `accessibilityAlignment` and `horizontalAlignment` would overwrite one
  another.
- Break a temporary retain cycle in `.system` presentation style

### Changed
- `CollectionViewConfiguration.usesBatchUpdatesForAllReloads` now defaults to `true`.
- Changed `CollectionViewConfiguration` from an immutable `class` to a `struct` to make it easier to
  modify an existing configuration.

## [0.4.0](https://github.com/airbnb/epoxy-ios/compare/0.3.0...0.4.0) - 2021-05-17

### Added
- Added an example with text field to show how can we use `avoidsKeyboard` feature
- Add EpoxyLayoutGroups, a declarative API for creating components

### Fixed
- `AnyItemModel` is selectable when there are no `DidSelect` callbacks on the underlying model

## [0.3.0](https://github.com/airbnb/epoxy-ios/compare/0.2.0...0.3.0) - 2021-04-23

### Added
- Added support for `Array` and `Optional` expressions to model result builders
- Added support for `Optional` expressions to `PresentationModel` result builders
- Made `AnyItemModel` and `AnySupplementaryItemModel` conform to `DidChangeStateProviding`,
  `DidChangeStateProviding` and `SetBehaviorsProviding`
- Made `AnyItemModel`, `AnySupplementaryItemModel`, and `AnyBarModel` conform to `StyleIDProviding`
- Adds a `keyboardContentInsetAdjustment` property to `UIScrollView` with the amount that the that
  its `contentInset.bottom` has been adjusted to accommodate for the keyboard by a
  `KeyboardPositionWatcher`
- Made `ItemSelectionStyle` conform to `Hashable`
- `ReuseIDStore` has a new method to vend a previously registered reuse ID,
  `registeredReuseID(for:)`

### Fixed
- Bar installers gracefully handle redundant calls to install/uninstall
- `CollectionView` more gracefully handles styleID mutations after registration

### Changed
- `ReuseIDStore.registerReuseID(for:)` has been renamed to `ReuseIDStore.reuseID(byRegistering:)`

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
