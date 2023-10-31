// Created by eric_horacek on 2/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import UIKit

extension UIViewController {
  /// The original safe area inset top before the additional safe area insets are applied.
  @nonobjc
  var originalSafeAreaInsetTop: CGFloat {
    view.safeAreaInsets.top - additionalSafeAreaInsets.top
  }

  /// The original safe area inset bottom before the additional safe area insets are applied.
  @nonobjc
  var originalSafeAreaInsetBottom: CGFloat {
    view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom
  }
}
