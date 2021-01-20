//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// A delegate that's invoked as the items in a `CollectionView` appear and disappear.
///
/// - SeeAlso: `WillDisplayProviding`
/// - SeeAlso: `DidEndDisplayingProviding`
public protocol CollectionViewDisplayDelegate: AnyObject {
  /// Called when an item is about to be displayed.
  ///
  /// Corresponds to `UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)`.
  func collectionView(
    _ collectionView: CollectionView,
    willDisplayItem item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)

  /// Called after an item ends displaying.
  ///
  /// Corresponds to `UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)`.
  func collectionView(
    _ collectionView: CollectionView,
    didEndDisplayingItem item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)

  /// Called when a supplementary item is about to be displayed.
  ///
  /// Corresponds to
  /// `UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)`.
  func collectionView(
    _ collectionView: CollectionView,
    willDisplaySupplementaryItem item: AnySupplementaryItemModel,
    forElementKind elementKind: String,
    with view: UIView?,
    in section: SectionModel)

  /// Called after a supplementary item ends displaying.
  ///
  /// Corresponds to
  /// `UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)`.
  func collectionView(
    _ collectionView: CollectionView,
    didEndDisplayingSupplementaryItem item: AnySupplementaryItemModel,
    forElementKind elementKind: String,
    with view: UIView?,
    in section: SectionModel)
}
