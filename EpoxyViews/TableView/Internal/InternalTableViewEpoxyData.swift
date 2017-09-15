//  Created by Laura Skelton on 12/4/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import Foundation

// MARK: InternalTableViewEpoxyData

/// An internal data structure constructed from an array of `EpoxySection`s that is specific
/// to display in a `UITableView` implementation.
public final class InternalTableViewEpoxyData: InternalEpoxyDataType {

  public typealias Item = InternalTableViewEpoxyModel
  public typealias ExternalSection = EpoxySection
  public typealias InternalSection = InternalTableViewEpoxySection

  init(
    sections: [InternalTableViewEpoxySection],
    sectionIndexMap: [String: Int],
    itemIndexMap: [String: IndexPath])
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
  }

  public fileprivate(set) var sections: [InternalTableViewEpoxySection]

  // MARK: Fileprivate

  fileprivate var sectionIndexMap = [String: Int]()
  fileprivate var itemIndexMap = [String: IndexPath]()

}

extension InternalTableViewEpoxyData {

  public static func make(with sections: [EpoxySection]) -> InternalTableViewEpoxyData {

    var sectionIndexMap = [String: Int]()
    var itemIndexMap = [String: IndexPath]()

    let lastSectionIndex = sections.count - 1
    let sections: [InternalTableViewEpoxySection] = sections.enumerated().map { sectionIndex, section in

      sectionIndexMap[section.dataID] = sectionIndex

      var itemIndex = 0

      var items = [InternalTableViewEpoxyModel]()

      // Note: Default UITableView section headers are "sticky" at the top of the page.
      // We don't want this behavior, so we are implementing our section headers as cells
      // in the UITableView implementation.
      if let existingSectionHeader = section.sectionHeader {
        items.append(InternalTableViewEpoxyModel(
          epoxyModel: existingSectionHeader,
          dividerType: .sectionHeaderDivider))

        if let dataID = existingSectionHeader.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      section.items.forEach { model in
        items.append(InternalTableViewEpoxyModel(
          epoxyModel: model,
          dividerType: .rowDivider))

        if let dataID = model.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      if sectionIndex == lastSectionIndex && !items.isEmpty {
        let lastModel = items.removeLast() // Remove last row divider
        items.append(InternalTableViewEpoxyModel(
          epoxyModel: lastModel.epoxyModel,
          dividerType: .none))
      }

      return InternalTableViewEpoxySection(
        dataID: section.dataID,
        items: items)
    }

    return InternalTableViewEpoxyData(
      sections: sections,
      sectionIndexMap: sectionIndexMap,
      itemIndexMap: itemIndexMap)
  }

  public func makeChangeset(from
    otherData: InternalTableViewEpoxyData) -> EpoxyChangeset
  {
    let sectionChangeset = sections.makeIndexSetChangeset(from: otherData.sections)

    var itemChangesetsForSections = [IndexPathChangeset]()
    for i in 0..<otherData.sections.count {
      if let newSectionIndex = sectionChangeset.newIndices[i]! {

        let fromSection = i
        let toSection = newSectionIndex

        let fromArray = otherData.sections[fromSection].items
        let toArray = sections[toSection].items

        let itemIndexChangeset = toArray.makeIndexPathChangeset(
          from: fromArray,
          fromSection: fromSection,
          toSection: toSection)

        itemChangesetsForSections.append(itemIndexChangeset)
      }
    }

    let itemChangeset: IndexPathChangeset = itemChangesetsForSections.reduce(IndexPathChangeset(), +)

    return EpoxyChangeset(
      sectionChangeset: sectionChangeset,
      itemChangeset: itemChangeset)
  }

  public func updateItem(at dataID: String, with item: EpoxyableModel) -> IndexPath? {
    guard let indexPath = itemIndexMap[dataID] else {
      assert(false, "No model with that dataID exists")
      return nil
    }

    let oldItem = sections[indexPath.section].items[indexPath.item]

    assert(oldItem.epoxyModel.reuseID == item.reuseID, "Cannot update model with a different reuse ID.")

    sections[indexPath.section].items[indexPath.item] = InternalTableViewEpoxyModel(
      epoxyModel: item,
      dividerType: oldItem.dividerType)

    return indexPath
  }

  public func indexPathForItem(at dataID: String) -> IndexPath? {
    return itemIndexMap[dataID]
  }
}

// MARK: InternalTableViewEpoxySection

/// A section in the `InternalTableViewEpoxyData`.
public struct InternalTableViewEpoxySection {

  init(
    dataID: String,
    items: [InternalTableViewEpoxyModel])
  {
    self.dataID = dataID
    self.items = items
  }

  public let dataID: String
  public fileprivate(set) var items: [InternalTableViewEpoxyModel]
}

extension InternalTableViewEpoxySection: EpoxyableSection {

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
    return [:]
  }
}

extension InternalTableViewEpoxySection: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? InternalTableViewEpoxySection else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String? {
    return dataID
  }
}

// MARK: EpoxyModelDividerType

/// Tells the cell which divider type to use in a view pinned to the cell's bottom.
public enum EpoxyModelDividerType {
  case rowDivider
  case sectionHeaderDivider
  case none
}

// MARK: InternalTableViewEpoxyModel

/// A model in a `InternalTableViewEpoxySection`, representing either a row or a section header.
public struct InternalTableViewEpoxyModel {

  init(
    epoxyModel: EpoxyableModel,
    dividerType: EpoxyModelDividerType)
  {
    self.epoxyModel = epoxyModel
    self.dividerType = dividerType
  }

  let epoxyModel: EpoxyableModel
  var dividerType: EpoxyModelDividerType
}

extension InternalTableViewEpoxyModel: EpoxyableModel {

  public var reuseID: String {
    return epoxyModel.reuseID
  }

  public var dataID: String? {
    return epoxyModel.dataID
  }

  public var isSelectable: Bool {
    return epoxyModel.isSelectable
  }

  public func configure(cell: EpoxyCell, animated: Bool) {
    epoxyModel.configure(cell: cell, animated: animated)
  }

  public func setBehavior(cell: EpoxyCell) {
    epoxyModel.setBehavior(cell: cell)
  }

  public func configure(cell: EpoxyCell, forState state: EpoxyCellState) {
    epoxyModel.configure(cell: cell, forState: state)
  }

  public func didSelect(_ cell: EpoxyCell) {
    epoxyModel.didSelect(cell)
  }
}

extension InternalTableViewEpoxyModel: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableEpoxyModel = otherDiffableItem as? InternalTableViewEpoxyModel else { return false }
    return epoxyModel.isDiffableItemEqual(to: otherDiffableEpoxyModel.epoxyModel)
  }

  public var diffIdentifier: String? {
    return epoxyModel.diffIdentifier
  }
}
