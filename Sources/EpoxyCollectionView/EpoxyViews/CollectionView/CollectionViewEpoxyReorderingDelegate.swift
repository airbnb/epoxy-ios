//  Created by shunji_li on 10/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation
import UIKit

public protocol CollectionViewEpoxyReorderingDelegate: AnyObject {
  func collectionView(
    _ collectionView: UICollectionView,
    moveItemWithDataID dataID: AnyHashable,
    inSectionWithDataID fromSectionDataID: AnyHashable,
    toSectionWithDataID toSectionDataID: AnyHashable,
    withDestinationDataId destinationDataId: AnyHashable)
}
