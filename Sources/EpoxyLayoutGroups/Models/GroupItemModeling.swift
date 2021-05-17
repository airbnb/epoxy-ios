// Created by Tyler Hedrick on 3/18/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import Foundation

// MARK: - GroupItemModeling

/// A type-erased representation of an item in a group
public protocol GroupItemModeling: Diffable {
  /// Returns this item model with its type erased to the `AnyGroupItem` type.
  func eraseToAnyGroupItem() -> AnyGroupItem
}

extension Array where Element == GroupItemModeling {
  public func eraseToAnyGroupItems() -> [AnyGroupItem] {
    map { $0.eraseToAnyGroupItem() }
  }
}
