// Created by Bryan Keller on 2/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// A singleton that enables consumers to control how Epoxy's internal implementation behaves across
// the entire app, without needing to update every place that uses Epoxy. This singleton is a
// temporary addition to Epoxy that enables us to test some implementation changes that are too
// risky to enable without having a way to turn them off via a feature flag.
public final class GlobalEpoxyConfig {

  private init() { }

  public static let shared = GlobalEpoxyConfig()

  // UIKit engineers have suggested that we should never call `reloadData` ourselves, and instead,
  // use batch updates for all data changes.
  public var usesBatchUpdatesForAllReloads = false

  // In the past, UICollectionView has crashed when prefetching was enabled. There were also some
  // other issues:
  //
  // - Rendering issues on iOS 10, 11 and maybe newer versions when using self-sizing supplementary
  // views.
  // - Invalidation issues on iOS 10, 11 and maybe newer versions when using self-sizing
  // supplementary views.
  // - Scroll-jumpiness issues (https://openradar.appspot.com/radar?id=4970013802889216).
  //
  // If this is set to `true`, then cell-prefetching will be turned on by default.
  public var usesCellPrefetching = false

  // Collection view does not accurately scroll to items if they're self-sized, due to it using
  // estimated heights to calculate the final offset. Setting this to true will cause collection
  // Epoxy to use a custom scroll-to-item implementation which is more accurate.
  public var usesAccurateScrollToItem = true
  
}
