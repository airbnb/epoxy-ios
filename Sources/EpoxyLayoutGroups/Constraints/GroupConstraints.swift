// Created by Tyler Hedrick on 5/13/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

/// A protocol to abstract the constraints needed for a given Group
protocol GroupConstraints {
  /// Spacing between items in the group
  var itemSpacing: CGFloat { get set }
  /// A set of all NSLayoutConstraints this constraint container contains
  var allConstraints: [NSLayoutConstraint] { get }

  /// Install all constraints
  func install()
  /// Uninstall all constraints
  func uninstall()
}
