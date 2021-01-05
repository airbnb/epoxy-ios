//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public protocol CollectionViewDisplayDelegate: AnyObject {
  func collectionView(
    _ collectionView: CollectionView,
    willDisplayItem item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)

  func collectionView(
    _ collectionView: CollectionView,
    didEndDisplayingItem item: AnyItemModel,
    with view: UIView?,
    in section: SectionModel)

  func collectionView(
    _ collectionView: CollectionView,
    willDisplaySupplementaryItem item: AnySupplementaryItemModel,
    forElementKind elementKind: String,
    with view: UIView?,
    in section: SectionModel)

  func collectionView(
    _ collectionView: CollectionView,
    didEndDisplayingSupplementaryItem item: AnySupplementaryItemModel,
    forElementKind elementKind: String,
    with view: UIView?,
    in section: SectionModel)
}
