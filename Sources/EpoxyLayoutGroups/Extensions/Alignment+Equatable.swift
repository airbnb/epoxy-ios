// Created by Tyler Hedrick on 6/8/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import UIKit

// MARK: - VGroup.ItemAlignment + Equatable

extension VGroup.ItemAlignment: Equatable {
  public static func ==(
    lhs: VGroup.ItemAlignment,
    rhs: VGroup.ItemAlignment)
    -> Bool
  {
    switch (lhs, rhs) {
    case (.fill, .fill),
         (.leading, .leading),
         (.center, .center),
         (.trailing, .trailing):
      return true
    case let (.centered(c1), .centered(c2)):
      return c1.isEqual(to: c2)
    case (.custom(let id1, _), .custom(let id2, _)):
      return id1 == id2
    default:
      return false
    }
  }
}

// MARK: - HGroup.ItemAlignment + Equatable

extension HGroup.ItemAlignment: Equatable {
  public static func ==(
    lhs: HGroup.ItemAlignment,
    rhs: HGroup.ItemAlignment)
    -> Bool
  {
    switch (lhs, rhs) {
    case (.fill, .fill),
         (.top, .top),
         (.center, .center),
         (.bottom, .bottom):
      return true
    case let (.centered(c1), .centered(c2)):
      return c1.isEqual(to: c2)
    case (.custom(let id1, _), .custom(let id2, _)):
      return id1 == id2
    default:
      return false
    }
  }
}
