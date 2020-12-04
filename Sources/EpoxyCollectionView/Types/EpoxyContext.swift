// Created by Tyler Hedrick on 9/26/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// An object used to provide context to blocks on `EpoxyModel`.
///
/// This object contains everything you need for configuration, removing the need to have multiple
/// parameters for each closure.
public final class EpoxyContext<View: UIView, Content: Equatable> {

  // MARK: Lifecycle

  public init(
    view: View,
    content: Content,
    dataID: AnyHashable,
    traitCollection: UITraitCollection,
    cellState: EpoxyCellState,
    animated: Bool)
  {
    self.view = view
    self.content = content
    self.dataID = dataID
    self.traitCollection = traitCollection
    self.cellState = cellState
    self.animated = animated
  }

  public convenience init(
    view: View,
    content: Content,
    dataID: AnyHashable,
    metadata: EpoxyViewMetadata)
  {
    self.init(
      view: view,
      content: content,
      dataID: dataID,
      traitCollection: metadata.traitCollection,
      cellState: metadata.state,
      animated: metadata.animated)
  }

  // MARK: Public

  public let view: View
  public let content: Content
  public let dataID: AnyHashable
  public let traitCollection: UITraitCollection
  public let cellState: EpoxyCellState
  public let animated: Bool

}
