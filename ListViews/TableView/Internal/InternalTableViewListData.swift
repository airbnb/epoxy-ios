//  Created by Laura Skelton on 12/4/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import Foundation

// MARK: InternalTableViewListData

/// An internal data structure constructed from an array of `ListSection`s that is specific
/// to display in a `UITableView` implementation.
public final class InternalTableViewListData: DiffableInternalListDataType {

  public typealias Changeset = InternalTableViewListDataChangeset
  public typealias Item = InternalTableViewListItem

  init(
    sections: [InternalTableViewListSection],
    sectionIndexMap: [String: Int],
    itemIndexMap: [String: IndexPath])
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
  }

  var sections: [InternalTableViewListSection]

  // MARK: Fileprivate

  fileprivate var sectionIndexMap = [String: Int]()
  fileprivate var itemIndexMap = [String: IndexPath]()

}

extension InternalTableViewListData {

  public static func make(with sections: [ListSection]) -> InternalTableViewListData {

    var sectionIndexMap = [String: Int]()
    var itemIndexMap = [String: IndexPath]()

    let lastSectionIndex = sections.count - 1
    let sections: [InternalTableViewListSection] = sections.enumerated().map { sectionIndex, section in

      sectionIndexMap[section.dataID] = sectionIndex

      var itemIndex = 0

      var items = [InternalTableViewListItem]()

      // Note: Default UITableView section headers are "sticky" at the top of the page.
      // We don't want this behavior, so we are implementing our section headers as cells
      // in the UITableView implementation.
      if let existingSectionHeader = section.sectionHeader {
        items.append(InternalTableViewListItem(
          listItem: existingSectionHeader,
          dividerType: .sectionHeaderDivider))

        if let dataID = existingSectionHeader.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      section.items.forEach { item in
        items.append(InternalTableViewListItem(
          listItem: item,
          dividerType: .rowDivider))

        if let dataID = item.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      if sectionIndex == lastSectionIndex && !items.isEmpty {
        let lastItem = items.removeLast() // Remove last row divider
        items.append(InternalTableViewListItem(
          listItem: lastItem.listItem,
          dividerType: .none))
      }

      return InternalTableViewListSection(
        dataID: section.dataID,
        items: items)
    }

    return InternalTableViewListData(
      sections: sections,
      sectionIndexMap: sectionIndexMap,
      itemIndexMap: itemIndexMap)
  }

  public func makeChangeset(from
    otherStructure: InternalTableViewListData) -> InternalTableViewListDataChangeset
  {
    let sectionChangeset = sections.makeIndexSetChangeset(from: otherStructure.sections)

    var itemChangesetsForSections = [IndexPathChangeset]()
    for i in 0..<otherStructure.sections.count {
      if let newSectionIndex = sectionChangeset.newIndices[i]! {

        let fromSection = i
        let toSection = newSectionIndex

        let fromArray = otherStructure.sections[fromSection].items
        let toArray = sections[toSection].items

        let itemIndexChangeset = toArray.makeIndexPathChangeset(
          from: fromArray,
          fromSection: fromSection,
          toSection: toSection)

        itemChangesetsForSections.append(itemIndexChangeset)
      }
    }

    let itemChangeset: IndexPathChangeset = itemChangesetsForSections.reduce(IndexPathChangeset(), +)

    return InternalTableViewListDataChangeset(
      sectionChangeset: sectionChangeset,
      itemChangeset: itemChangeset)
  }

  public func updateItem(at dataID: String, with item: ListItem) -> IndexPath? {
    guard let indexPath = itemIndexMap[dataID] else {
      assert(false, "No item with that dataID exists")
      return nil
    }

    let oldItem = sections[indexPath.section].items[indexPath.item]

    assert(oldItem.listItem.reuseID == item.reuseID, "Cannot update item with a different reuse ID.")

    sections[indexPath.section].items[indexPath.item] = InternalTableViewListItem(
      listItem: item,
      dividerType: oldItem.dividerType)

    return indexPath
  }

}

/// An internal data changeset for use in updating a `UITableView`.
public struct InternalTableViewListDataChangeset {

  init(
    sectionChangeset: IndexSetChangeset,
    itemChangeset: IndexPathChangeset)
  {
    self.sectionChangeset = sectionChangeset
    self.itemChangeset = itemChangeset
  }

  let sectionChangeset: IndexSetChangeset
  let itemChangeset: IndexPathChangeset
}

// MARK: InternalTableViewListSection

/// A section in the `InternalTableViewListData`.
public struct InternalTableViewListSection {

  init(
    dataID: String,
    items: [InternalTableViewListItem])
  {
    self.dataID = dataID
    self.items = items
  }

  let dataID: String
  var items: [InternalTableViewListItem]
}

extension InternalTableViewListSection: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? InternalTableViewListSection else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String? {
    return dataID
  }
}

// MARK: ListItemDividerType

/// Tells the cell which divider type to use in a view pinned to the cell's bottom.
public enum ListItemDividerType {
  case rowDivider
  case sectionHeaderDivider
  case none
}

// MARK: InternalTableViewListItem

/// An item in a `InternalTableViewListSection`, representing either a row or a section header.
public struct InternalTableViewListItem {

  init(
    listItem: ListItem,
    dividerType: ListItemDividerType)
  {
    self.listItem = listItem
    self.dividerType = dividerType
  }

  let listItem: ListItem
  var dividerType: ListItemDividerType
}

extension InternalTableViewListItem: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableListItem = otherDiffableItem as? InternalTableViewListItem else { return false }
    return listItem.isDiffableItemEqual(to: otherDiffableListItem.listItem)
  }

  public var diffIdentifier: String? {
    return listItem.diffIdentifier
  }
}
