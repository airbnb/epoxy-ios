//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public protocol CollectionViewEpoxyItemDisplayDelegate: AnyObject {
  func collectionView(
    _ collectionView: CollectionView,
    willDisplayEpoxyModel epoxyModel: EpoxyableModel,
    in section: EpoxyableSection)

  func collectionView(
    _ collectionView: CollectionView,
    didEndDisplayingEpoxyModel epoxyModel: EpoxyableModel,
    in section: EpoxyableSection)

  func collectionView(
    _ collectionView: CollectionView,
    willDisplaySupplementaryEpoxyModel epoxyModel: SupplementaryViewEpoxyableModel,
    with view: UIView?,
    in section: EpoxyableSection)

  func collectionView(
    _ collectionView: CollectionView,
    didEndDisplayingSupplementaryEpoxyModel epoxyModel: SupplementaryViewEpoxyableModel,
    with view: UIView?,
    in section: EpoxyableSection)
}
