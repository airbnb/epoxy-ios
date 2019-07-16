// Created by nick_miller on 7/15/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

protocol TableViewCellAccessibilityDelegate: class {
  func tableViewCellDidBecomeFocused(cell: TableViewCell)
  func tableViewCellDidLoseFocus(cell: TableViewCell)
}

