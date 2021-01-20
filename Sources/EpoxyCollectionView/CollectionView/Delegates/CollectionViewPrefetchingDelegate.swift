//  Created by eric_horacek on 4/2/18.
//  Copyright © 2018 Airbnb. All rights reserved.

/// A delegate that's invoked as the content of items in a `CollectionView` flows through the
/// lifecycle of prefetching.
///
/// - Note: prefetching must be enabled on the `CollectionViewConfiguration` via
/// `usesCellPrefetching` for these methods to be called.
public protocol CollectionViewPrefetchingDelegate: AnyObject {
  /// Invoked when the given items should be prefetched.
  ///
  /// Corresponds to `UICollectionViewDataSourcePrefetching.collectionView(_:prefetchItemsAt:)`.
  func collectionView(
    _ collectionView: CollectionView,
    prefetch items: [AnyItemModel])

  /// Invoked when the prefetching for the given items should be cancelled.
  ///
  /// Corresponds to
  /// `UICollectionViewDataSourcePrefetching.collectionView(_:cancelPrefetchingForItemsAt:)`.
  func collectionView(
    _ collectionView: CollectionView,
    cancelPrefetchingOf items: [AnyItemModel])
}
