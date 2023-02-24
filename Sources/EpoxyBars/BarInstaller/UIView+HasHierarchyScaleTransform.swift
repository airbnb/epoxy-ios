// Created by eric_horacek on 2/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - UIView

extension UIView {
  /// Whether this view has a scale in its view hierarchy at any point in the
  /// given number of ancestor views.
  @nonobjc
  func hasHierarchyScaleTransform(below ancestor: Int = 10) -> Bool {
    guard ancestor > 0 else {
      return false
    }

    guard CATransform3DEqualToTransform(transform3D, CATransform3DIdentity) else {
      // m11, m22, and m33 correspond to x, y, and z scale respectively.
      return transform3D.m11 != 1.0 || transform3D.m22 != 1.0 || transform3D.m33 != 1.0 
    }

    return superview?.hasHierarchyScaleTransform(below: ancestor - 1) ?? false
  }
}
