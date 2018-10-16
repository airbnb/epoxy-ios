//  Created by bryan_keller on 7/24/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// Represents additional sizing mode information for a dimension (width or height)
public enum DimensionSizeMode {
  case `static`
  case dynamic

  // The priority to use when calculating the fitting size for a collection view element
  public var fittingPriority: UILayoutPriority {
    switch self {
    case .static:
      return .required
    case .dynamic:
      return .fittingSizeLevel
    }
  }
}

/// A protocol that provides additional sizing mode information for a `CollectionViewCell`, via the layout attributes passed in to `preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)`
public protocol CollectionViewLayoutAttributes {

  var widthSizeMode: DimensionSizeMode { get }
  var heightSizeMode: DimensionSizeMode { get }

}

extension CollectionViewLayoutAttributes {

  public var widthSizeMode: DimensionSizeMode {
    return .dynamic
  }

  public var heightSizeMode: DimensionSizeMode {
    return .dynamic
  }

}
