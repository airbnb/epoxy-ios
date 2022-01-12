//  Created by shunji_li on 10/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// A delegate that's invoked when the items in a `CollectionView` are moved using the legacy
/// drag/drop system.
///
/// - Note: Corresponds to the legacy `UICollectionViewDataSource.collectionView(_:moveItemAt:to:)`
/// drag/drop system, not the modern `UICollectionViewDragDelegate`/`UICollectionViewDropDelegate`
/// system.
///
/// - SeeAlso: `IsMovableProviding`
public protocol CollectionViewReorderingDelegate: AnyObject {

  /// Returns whether the source item is allowed to move to the proposed destination.
  ///
  /// If `false`, the destination item will be pinned and the interactive item cannot be moved to 
  /// the destination position. Defaults to `true`.
  ///
  /// Corresponds to 
  /// `UICollectionViewDelegate.collectionView(_:targetIndexPathForMoveFromItemAt:toProposedIndexPath:)`
  func collectionView(
    _ collectionView: CollectionView,
    shouldMoveItem sourceItem: AnyItemModel,
    inSection sourceSection: SectionModel,
    toDestinationItem destinationItem: AnyItemModel,
    inSection destinationSection: SectionModel) -> Bool

  /// Move the specified item to the given new location.
  ///
  /// Corresponds to `UICollectionViewDataSource.collectionView(_:moveItemAt:to:)`.
  func collectionView(
    _ collectionView: CollectionView,
    moveItem sourceItem: AnyItemModel,
    inSection sourceSection: SectionModel,
    toDestinationItem destinationItem: AnyItemModel,
    inSection destinationSection: SectionModel)
}

extension CollectionViewReorderingDelegate {

  public func collectionView(
    _ collectionView: CollectionView,
    shouldMoveItem sourceItem: AnyItemModel,
    inSection sourceSection: SectionModel,
    toDestinationItem destinationItem: AnyItemModel,
    inSection destinationSection: SectionModel) -> Bool
  {
    true
  }
}
