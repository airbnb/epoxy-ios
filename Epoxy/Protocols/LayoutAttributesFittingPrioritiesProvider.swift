//  Created by bryan_keller on 12/4/18.
//  Copyright © 2018 Airbnb. All rights reserved.

import UIKit

/// A protocol that provides additional sizing mode information for a `CollectionViewCell`,
/// via the layout attributes passed in to
/// `preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)`.
public protocol LayoutAttributesFittingPrioritiesProvider {

  var horizontalFittingPriority: UILayoutPriority { get }
  var verticalFittingPriority: UILayoutPriority { get }

}
