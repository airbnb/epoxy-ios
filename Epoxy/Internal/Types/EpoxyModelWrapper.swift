// Created by Tyler Hedrick on 5/13/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Foundation

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

  public func configure(cell: EpoxyWrapperView, forTraitCollection traitCollection: UITraitCollection, animated: Bool) {
    epoxyModel.configure(cell: cell, forTraitCollection: traitCollection, animated: animated)
  }

  public func setBehavior(cell: EpoxyWrapperView) {
    epoxyModel.setBehavior(cell: cell)
  }

  public func configure(cell: EpoxyWrapperView, forTraitCollection traitCollection: UITraitCollection, state: EpoxyCellState) {
    epoxyModel.configure(cell: cell, forTraitCollection: traitCollection, state: state)
  }

  public func didSelect(_ cell: EpoxyWrapperView) {
    epoxyModel.didSelect(cell)
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
