//  Created by bryan_keller on 7/24/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// Represents additional sizing mode information for a dimension (width or height)
enum DimensionSizeMode {
  case `static`
  case dynamic
}

/// A protocol that provides additional sizing mode information for a `CollectionViewCell`, via the layout attributes passed in to `preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)`
protocol CollectionViewLayoutAttributes {

  var widthSizeMode: DimensionSizeMode { get }
  var heightSizeMode: DimensionSizeMode { get }

}

extension CollectionViewLayoutAttributes {

  var widthSizeMode: DimensionSizeMode {
    return .dynamic
  }

  var heightSizeMode: DimensionSizeMode {
    return .dynamic
  }

}
