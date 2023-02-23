// Created by eric_horacek on 2/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - UIView

extension UIView {
  /// Whether this view has a non-identity 3D transform in its view hierarchy at any point in the
  /// given number of ancestor views.
  @nonobjc
  func hasHierarchy3DTransform(below ancestor: Int = 10) -> Bool {
    guard ancestor > 0 else {
      return false
    }

    guard CATransform3DEqualToTransform(transform3D, CATransform3DIdentity) else {
      return true
    }

    return superview?.hasHierarchy3DTransform(below: ancestor - 1) ?? false
  }
}
