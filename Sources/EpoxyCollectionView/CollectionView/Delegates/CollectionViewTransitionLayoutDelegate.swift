//  Created by eric_horacek on 9/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// A delegate that's invoked when to transition between `UICollectionViewLayout` in a
/// `CollectionView`.
public protocol CollectionViewTransitionLayoutDelegate: AnyObject {
  /// Asks for the custom transition layout to use when moving between the specified layouts.
  ///
  /// Corresponds to
  /// `UICollectionViewDelegate.collectionView(_:transitionLayoutForOldLayout:newLayout:)`.
  func collectionView(
    _ collectionView: CollectionView,
    transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
    newLayout toLayout: UICollectionViewLayout)
    -> UICollectionViewTransitionLayout
}
