//  Created by gonzalo_nunez on 6/26/17.
//  Copyright © 2017 Airbnb, Inc. All rights reserved.

import UIKit

extension UIView {

  /// Returns the receiver's calculated height given a width
  public func compressedHeight(forWidth width: CGFloat) -> CGFloat {
    let widthConstraint = widthAnchor.constraint(equalToConstant: width)
    widthConstraint.isActive = true
    let height = systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    widthConstraint.isActive = false
    return height
  }

}
