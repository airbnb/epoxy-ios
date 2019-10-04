// Created by Tyler Hedrick on 5/13/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import UIKit

/// The diffing algorithm complains at compile time without this concrete wrapper
public final class EpoxyModelWrapper {

  init(epoxyModel: EpoxyableModel) {
    self.epoxyModel = epoxyModel
  }

  let epoxyModel: EpoxyableModel
  var extraModelWrapperInfo: [EpoxyUserInfoKey: Any] = [:]
}

extension EpoxyModelWrapper: EpoxyableModel {

  public var reuseID: String {
    return epoxyModel.reuseID
  }

  public var dataID: String {
    return epoxyModel.dataID
  }

  public var selectionStyle: CellSelectionStyle? {
    get { return epoxyModel.selectionStyle }
    set { epoxyModel.selectionStyle = newValue }
  }

  public var isSelectable: Bool {
    get { return epoxyModel.isSelectable }
    set { epoxyModel.isSelectable = newValue }
  }

  public var isMovable: Bool {
    return epoxyModel.isMovable
  }

  public var userInfo: [EpoxyUserInfoKey : Any] {
    return epoxyModel.userInfo
  }

  public func configure(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    epoxyModel.configure(cell: cell, with: metadata)
  }

  public func setBehavior(cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    epoxyModel.setBehavior(cell: cell, with: metadata)
  }

  public func configureStateChange(in cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    epoxyModel.configureStateChange(in: cell, with: metadata)
  }

  public func didSelect(_ cell: EpoxyWrapperView, with metadata: EpoxyViewMetadata) {
    epoxyModel.didSelect(cell, with: metadata)
  }

  public func willDisplay() {
    epoxyModel.willDisplay()
  }

  public func didEndDisplaying() {
    epoxyModel.didEndDisplaying()
  }
}

extension EpoxyModelWrapper: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableEpoxyItem = otherDiffableItem as? EpoxyModelWrapper else { return false }
    return epoxyModel.isDiffableItemEqual(to: otherDiffableEpoxyItem.epoxyModel)
  }

  public var diffIdentifier: String? {
    return epoxyModel.diffIdentifier
  }
}
