// Created by nick_miller on 7/16/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// A delegate that's invoked as item gain and lose accessibility focus on a `CollectionView`.
public protocol CollectionViewAccessibilityDelegate: AnyObject {
  /// Called when an item gains accessibility focus.
  ///
  /// Corresponds to `UICollectionViewCell.accessibilityElementDidBecomeFocused()`
  func collectionView(
    _ collectionView: CollectionView,
    itemDidBecomeFocused item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)

  /// Called when an item loses accessibility focus.
  ///
  /// Corresponds to `UICollectionViewCell.accessibilityElementDidLoseFocus()`
  func collectionView(
    _ collectionView: CollectionView,
    itemDidLoseFocus item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)
}
