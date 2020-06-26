// Created by nick_miller on 7/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

public protocol TableViewAccessibilityDelegate: class {
  func tableView(
    _ tableView: DeprecatedTableView,
    epoxyModelDidBecomeFocused model: EpoxyableModel,
    with view: UIView?,
    in section: EpoxyableSection)

  func tableView(
    _ tableView: DeprecatedTableView,
    epoxyModelDidLoseFocus model: EpoxyableModel,
    with view: UIView?,
    in section: EpoxyableSection)
}
