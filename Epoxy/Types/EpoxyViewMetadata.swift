// Created by Tyler Hedrick on 9/27/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// Object used to pass around metadata for EpoxyModels & Cells
public struct EpoxyViewMetadata {
  public init(traitCollection: UITraitCollection, state: EpoxyCellState, animated: Bool) {
    self.traitCollection = traitCollection
    self.state = state
    self.animated = animated
  }

  public let traitCollection: UITraitCollection
  public let state: EpoxyCellState
  public let animated: Bool
}
