//  Created by bryn_bodayle on 2/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

public protocol CollectionViewEpoxyItemDisplayDelegate: class {
  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay epoxyItem: EpoxyableModel)
}