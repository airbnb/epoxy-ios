// Created by Bryan Keller on 2/24/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// A singleton that enables consumers to control how Epoxy's internal implementation behaves across
// the entire app, without needing to update every place that uses Epoxy. This singleton is a
// temporary addition to Epoxy that enables us to test some implementation changes that are too
// risky to enable without having a way to turn them off via a feature flag.
public final class GlobalEpoxyConfig {

  private init() { }

  public static let shared = GlobalEpoxyConfig()

  // Queing batch updates should not be necessary - there's no rate limit to collection view's batch
  // update API. Some notes on this topic:
  //
  // * Calling `performBatchUpdates` n times in a row results in n calls to
  //  `prepareForCollectionViewUpdates` and `finalizeCollectionViewUpdates`
  // * Updates are not coalesced, but also no updates are lost (see above bullet point)
  // * Collection view appears to just do one animation for all of the batch updates, not n
  //  independent / chained ones
  //
  // For these reasons, Epoxy probably shouldn’t do anything clever - if new data is provided,
  // simply perform a batch update. If a particular feature requires data update throttling, that’s
  // a specific feature requirement and can be implemented in feature code.
  public var disablesCVBatchUpdateQueuing = false

  // UIKit engineers have suggested that we should never call `reloadData` ourselves, and instead,
  // use batch updates for all data changes.
  public var usesBatchUpdatesForAllCVReloads = false

  // Collection view does not accurately scroll to items if they're self-sized, due to it using
  // estimated heights to calculate the final offset. Setting this to true will cause collection
  // Epoxy to drive the animation using a custom scroll-to-item system which is more accurate.
  public var usesAccurateAnimatedScrollToItem = false
  
}
