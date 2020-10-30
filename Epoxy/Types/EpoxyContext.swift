// Created by Tyler Hedrick on 9/26/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// An object used to pass context to blocks on EpoxyableModels
/// This object contains everything you need for a given block
/// removing the need to have multiple parameters for each block
public class EpoxyContext<ViewType: UIView, DataType: Equatable, DataID: Hashable> {
  init(
    view: ViewType,
    data: DataType,
    dataID: DataID,
    traitCollection: UITraitCollection,
    cellState: EpoxyCellState,
    animated: Bool)
  {
    self.view = view
    self.data = data
    self.dataID = dataID
    self.traitCollection = traitCollection
    self.cellState = cellState
    self.animated = animated
  }

  public let view: ViewType
  public let data: DataType
  public let dataID: DataID
  public let traitCollection: UITraitCollection
  public let cellState: EpoxyCellState
  public let animated: Bool
}
