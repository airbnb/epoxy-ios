// Created by Bryan Keller on 2/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

/// A singleton that enables consumers to control how `CollectionView`'s internal implementation
/// behaves across the entire app, without needing to update every place that uses it.
///
/// Can additionally be provided when initializing a `CollectionView` to customize the behavior of
/// that specific instance.
public struct CollectionViewConfiguration {

  // MARK: Lifecycle

  public init(
    usesBatchUpdatesForAllReloads: Bool = true,
    usesCellPrefetching: Bool = true,
    usesAccurateScrollToItem: Bool = true)
  {
    self.usesBatchUpdatesForAllReloads = usesBatchUpdatesForAllReloads
    self.usesCellPrefetching = usesCellPrefetching
    self.usesAccurateScrollToItem = usesAccurateScrollToItem
  }

  // MARK: Public

  /// The default configuration instance used if none is provided when initializing a
  /// `CollectionView`.
  ///
  /// Set this to a new instance to override the default configuration.
  public static var shared = CollectionViewConfiguration()

  /// When `true`, `CollectionView` performs non-animated content updates by wrapping a call to
  /// `performBatchUpdates(…)` with the new content within a `UIView.performWithoutAnimation(…)`
  /// closure.
  ///
  /// UIKit engineers have suggested that we should never call `reloadData(…)` ourselves, and
  /// instead, use batch updates for all data changes. `performBatchUpdates(…)` is more performant
  /// and reliable than `reloadData(…)`, as it does not recreate and reconfigure all visible cells.
  ///
  /// When `false`, `CollectionView` performs non-animated updates by calling `reloadData(…)`, which
  /// recreates and reconfigures all visible cells.
  ///
  /// Defaults to `true`.
  ///
  /// - SeeAlso: `CollectionView.UpdateStrategy`
  public var usesBatchUpdatesForAllReloads: Bool

  /// In the past, `UICollectionView` has crashed when prefetching was enabled. There were also some
  /// other issues:
  ///
  /// - Rendering issues on iOS 10, 11 and maybe newer versions when using self-sizing supplementary
  /// views.
  /// - Invalidation issues on iOS 10, 11 and maybe newer versions when using self-sizing
  /// supplementary views.
  /// - Scroll-jumpiness issues (https://openradar.appspot.com/radar?id=4970013802889216).
  ///
  /// If this is set to `true`, then cell-prefetching will be turned on by default.
  ///
  /// Defaults to `true`.
  public var usesCellPrefetching: Bool

  /// `UICollectionView` does not accurately scroll to items if they're self-sized, due to it using
  /// estimated heights to calculate the final offset. Setting this to `true` will cause
  /// `CollectionView` to use a custom scroll-to-item implementation which is more accurate.
  ///
  /// Defaults to `true`.
  ///
  /// - SeeAlso: `CollectionViewScrollToItemHelper`
  public var usesAccurateScrollToItem: Bool
}
