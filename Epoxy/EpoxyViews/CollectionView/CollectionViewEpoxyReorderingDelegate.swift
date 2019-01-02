//  Created by shunji_li on 10/9/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation
import UIKit

public protocol CollectionViewEpoxyReorderingDelegate: AnyObject {
  func collectionView(
    _ collectionView: UICollectionView,
    moveItemWithDataID dataID: String,
    inSectionWithDataID fromSectionDataID: String,
    toSectionWithDataID toSectionDataID: String,
    withDestinationDataId destinationDataId: String)
}
