// Created by nick_miller on 7/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public protocol EpoxyAccessibilityDelegate: class {
  func epoxyCellDidBecomeFocused(
    model: EpoxyableModel,
    view: UIView?,
    section: EpoxyableSection)

  func epoxyCellDidLoseFocus(
    model: EpoxyableModel,
    view: UIView?,
    section: EpoxyableSection)
}
