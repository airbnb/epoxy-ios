// Created by eric_horacek on 2/23/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - UIScrollView

extension UIScrollView {
  /// The content offset at which this scroll view is scrolled to its top.
  @nonobjc
  var topContentOffset: CGFloat {
    -adjustedContentInset.top
  }

  /// The content offset at which this scroll view is scrolled to its bottom.
  @nonobjc
  var bottomContentOffset: CGFloat {
    max(contentSize.height - bounds.height + adjustedContentInset.bottom, topContentOffset)
  }
}
