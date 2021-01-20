// Created by Tyler Hedrick on 9/27/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// The metadata describing an item view within a cell.
public struct ItemCellMetadata {

  // MARK: Lifecycle

  public init(traitCollection: UITraitCollection, state: ItemCellState, animated: Bool) {
    self.traitCollection = traitCollection
    self.state = state
    self.animated = animated
  }

  // MARK: Public

  public let traitCollection: UITraitCollection
  public let state: ItemCellState
  public let animated: Bool
}
