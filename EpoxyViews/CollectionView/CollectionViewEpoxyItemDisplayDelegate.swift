//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

public protocol CollectionViewEpoxyItemDisplayDelegate: class {
  func collectionView(
    _ collectionView: CollectionView,
    willDisplayEpoxyModel epoxyModel: EpoxyableModel,
    with view: UIView,
    in section: EpoxyableSection)

  func collectionView(
    _ collectionView: CollectionView,
    didEndDisplayingEpoxyModel epoxyModel: EpoxyableModel,
    with view: UIView,
    in section: EpoxyableSection)

  func collectionView(
    _ collectionView: CollectionView,
    willDisplaySupplementaryEpoxyModel epoxyModel: SupplementaryViewEpoxyableModel,
    with view: UIView,
    in section: EpoxyableSection)
}
