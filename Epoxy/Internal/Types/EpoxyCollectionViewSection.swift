//  Created by Laura Skelton on 9/7/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation
import UIKit

public struct EpoxyCollectionViewSection {

  // MARK: Lifecycle

  public init(
    dataID: String = "",
    items: [EpoxyableModel],
    supplementaryModels: [String: [SupplementaryViewEpoxyableModel]]? = nil,
    userInfo: [EpoxyUserInfoKey: Any] = [:])
  {
    self.dataID = dataID
    self.supplementaryModels = supplementaryModels
    self.items = items.map { item in
      return EpoxyModelWrapper(epoxyModel: item)
    }
    self.userInfo = userInfo
  }

  // MARK: Public

  /// The reference id for the model backing this section.
  public let dataID: String

  /// The data for the items to be displayed in this section.
  public var items: [EpoxyModelWrapper]

  /// Any additional layout data for the section
  public let supplementaryModels: [String: [SupplementaryViewEpoxyableModel]]?

  /// Any additional user-specific data needed for this section
  public let userInfo: [EpoxyUserInfoKey: Any]
}

// MARK: Diffable

extension EpoxyCollectionViewSection: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? EpoxyCollectionViewSection else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String? {
    return dataID
  }
}

// MARK: EpoxyableSection

extension EpoxyCollectionViewSection: EpoxyableSection {

  public var itemModels: [EpoxyableModel] {
    return items as [EpoxyableModel]
  }

  public func getCellReuseIDs() -> Set<String> {
    var newCellReuseIDs = Set<String>()
    items.forEach { item in
      newCellReuseIDs.insert(item.reuseID)
    }
    return newCellReuseIDs
  }

  public func getSupplementaryViewReuseIDs() -> [String: Set<String>] {
    var newSupplementaryViewReuseIDs = [String: Set<String>]()
    supplementaryModels?.forEach { elementKind, elementSupplementaryModels in
      var newElementSupplementaryViewReuseIDs = Set<String>()
      elementSupplementaryModels.forEach { elementSupplementaryModel in
        newElementSupplementaryViewReuseIDs.insert(elementSupplementaryModel.reuseID)
      }
      newSupplementaryViewReuseIDs[elementKind] = newElementSupplementaryViewReuseIDs
    }
    return newSupplementaryViewReuseIDs
  }
}

/// The diffing algorithm complains at compile time without this concrete wrapper
public final class EpoxyModelWrapper {

  init(
    epoxyModel: EpoxyableModel)
  {
    self.epoxyModel = epoxyModel
  }

  let epoxyModel: EpoxyableModel
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
