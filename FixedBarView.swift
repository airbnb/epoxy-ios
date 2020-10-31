// Created by Cal Stephens on 3/10/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - FixedBarView

/// Views that conform to this protocol are treated as "fixed" bars.
/// This includes navigation bars, toolbars, and tab bars.
public protocol FixedBarView {
  var barView: UIView { get }
}

public extension FixedBarView where Self: UIView {
  var barView: UIView { self }
}
