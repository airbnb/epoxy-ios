//  Created by Laura Skelton on 12/4/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import Foundation
import UIKit

// MARK: InternalTableViewEpoxyData

/// An internal data structure constructed from an array of `EpoxySection`s that is specific
/// to display in a `UITableView` implementation.
public final class InternalTableViewEpoxyData: InternalEpoxyDataType {
  init(
    sections: [InternalEpoxySection],
    sectionIndexMap: [AnyHashable: Int],
    itemIndexMap: [AnyHashable: IndexPath],
    epoxyLogger: EpoxyLogging)
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
    self.epoxyLogger = epoxyLogger
  }

  public fileprivate(set) var sections: [InternalEpoxySection]

  // MARK: Fileprivate

  fileprivate var sectionIndexMap = [AnyHashable: Int]()
  fileprivate var itemIndexMap = [AnyHashable: IndexPath]()
  fileprivate let epoxyLogger: EpoxyLogging
}

extension InternalTableViewEpoxyData {

  public static func make(
    with sections: [EpoxySection],
    epoxyLogger: EpoxyLogging)
    -> InternalTableViewEpoxyData
  {
    var sectionIndexMap = [AnyHashable: Int]()
    var itemIndexMap = [AnyHashable: IndexPath]()

    let lastSectionIndex = sections.count - 1
    let sections: [InternalEpoxySection] = sections.enumerated().map { sectionIndex, section in

      sectionIndexMap[section.dataID] = sectionIndex

      var itemIndex = 0

      var items = [EpoxyModelWrapper]()

      // Note: Default UITableView section headers are "sticky" at the top of the page.
      // We don't want this behavior, so we are implementing our section headers as cells
      // in the UITableView implementation.
      if let existingSectionHeader = section.tableViewSectionHeader {
        items.append(EpoxyModelWrapper(
          epoxyModel: existingSectionHeader,
          dividerType: existingSectionHeader.tableViewBottomDividerHidden ? .none : .sectionHeaderDivider))

        let dataID = existingSectionHeader.dataID
        itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)

        itemIndex += 1
      }

      section.items.forEach { model in
        items.append(EpoxyModelWrapper(
          epoxyModel: model,
          dividerType: model.tableViewBottomDividerHidden ? .none : .rowDivider))

        itemIndexMap[model.dataID] = IndexPath(item: itemIndex, section: sectionIndex)

        itemIndex += 1
      }

      if sectionIndex == lastSectionIndex && !items.isEmpty {
        let lastModel = items.removeLast() // Remove last row divider
        items.append(EpoxyModelWrapper(
          epoxyModel: lastModel.epoxyModel,
          dividerType: .none))
      }

      return InternalEpoxySection(
        dataID: section.dataID,
        items: items,
        userInfo: section.userInfo)
    }

    return InternalTableViewEpoxyData(
      sections: sections,
      sectionIndexMap: sectionIndexMap,
      itemIndexMap: itemIndexMap,
      epoxyLogger: epoxyLogger)
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

  public func updateItem(at dataID: AnyHashable, with item: EpoxyableModel) -> IndexPath? {
    guard let indexPath = itemIndexMap[dataID] else {
      epoxyLogger.epoxyAssert(false, "No model with that dataID exists")
      return nil
    }

    let oldItem = sections[indexPath.section].items[indexPath.item]

    epoxyLogger.epoxyAssert(oldItem.epoxyModel.reuseID == item.reuseID, "Cannot update model with a different reuse ID.")

    sections[indexPath.section].items[indexPath.item] = EpoxyModelWrapper(
      epoxyModel: item,
      dividerType: oldItem.dividerType)

    return indexPath
  }

  public func indexPathForItem(at dataID: AnyHashable) -> IndexPath? {
    return itemIndexMap[dataID]
  }

  public func indexForSection(at dataID: AnyHashable) -> Int? {
    return sectionIndexMap[dataID]
  }
}

// MARK: EpoxyModelDividerType

/// Tells the cell which divider type to use in a view pinned to the cell's bottom.
public enum EpoxyModelDividerType {
  case rowDivider
  case sectionHeaderDivider
  case none
}

extension EpoxyUserInfoKey.DeprecatedTableView.Row {
  public static var dividerType: EpoxyUserInfoKey {
    return EpoxyUserInfoKey(rawValue: "\(DeprecatedTableView.self)_\(#function)")
  }
}

extension EpoxyModelWrapper {
  convenience init(epoxyModel: EpoxyableModel, dividerType: EpoxyModelDividerType) {
    self.init(epoxyModel: epoxyModel)
    self.dividerType = dividerType
  }

  public var dividerType: EpoxyModelDividerType {
    set { extraModelWrapperInfo[EpoxyUserInfoKey.DeprecatedTableView.Row.dividerType] = newValue }
    get { return extraModelWrapperInfo[EpoxyUserInfoKey.DeprecatedTableView.Row.dividerType] as? EpoxyModelDividerType ?? .none }
  }
}
