// Created by Tyler Hedrick on 1/22/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

extension NSLayoutConstraint {
  public static func activate(_ constraints: [NSLayoutConstraint?]) {
    NSLayoutConstraint.activate(constraints.compactMap { $0 })
  }

  public static func deactivate(_ constraints: [NSLayoutConstraint?]) {
    NSLayoutConstraint.deactivate(constraints.compactMap { $0 })
  }
}
