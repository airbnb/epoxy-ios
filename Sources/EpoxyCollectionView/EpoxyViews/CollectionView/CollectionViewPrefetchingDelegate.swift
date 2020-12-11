//  Created by eric_horacek on 4/2/18.
//  Copyright © 2018 Airbnb. All rights reserved.

public protocol CollectionViewPrefetchingDelegate: AnyObject {
  func collectionView(
    _ collectionView: CollectionView,
    prefetch items: [AnyItemModel])

  func collectionView(
    _ collectionView: CollectionView,
    cancelPrefetchingOf items: [AnyItemModel])
}
