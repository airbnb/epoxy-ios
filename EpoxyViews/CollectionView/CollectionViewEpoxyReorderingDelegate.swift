//  Created by shunji_li on 10/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

public protocol CollectionViewEpoxyReorderingDelegate: class {
  func collectionView(
    _ collectionView: UICollectionView,
    moveItemWithDataID dataID: String,
    inSectionWithDataID fromSectionDataID: String,
    toSectionWithDataID toSectionDataID: String,
    beforeDataID toBeforeDataID: String?)
}
