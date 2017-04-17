//  Created by Laura Skelton on 12/4/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import Foundation

// MARK: ListInternalTableViewStructure

/// An internal data structure constructed from a `ListStructure` that is specific
/// to display in a `UITableView` implementation.
public final class ListInternalTableViewStructure: DiffableListInternalStructure {

  public typealias Changeset = ListInternalTableViewStructureChangeset
  public typealias Item = ListInternalTableViewItemStructure

  init(
    sections: [ListInternalTableViewSectionStructure],
    sectionIndexMap: [String: Int],
    itemIndexMap: [String: IndexPath])
  {
    self.sections = sections
    self.sectionIndexMap = sectionIndexMap
    self.itemIndexMap = itemIndexMap
  }

  var sections: [ListInternalTableViewSectionStructure]

  // MARK: Fileprivate

  fileprivate var sectionIndexMap = [String: Int]()
  fileprivate var itemIndexMap = [String: IndexPath]()

}

extension ListInternalTableViewStructure {

  public static func make(with listStructure: ListStructure) -> ListInternalTableViewStructure {

    var sectionIndexMap = [String: Int]()
    var itemIndexMap = [String: IndexPath]()

    let lastSectionIndex = listStructure.sections.count - 1
    let sections: [ListInternalTableViewSectionStructure] = listStructure.sections.enumerated().map { sectionIndex, section in

      sectionIndexMap[section.dataID] = sectionIndex

      var itemIndex = 0

      var items = [ListInternalTableViewItemStructure]()

      // Note: Default UITableView section headers are "sticky" at the top of the page.
      // We don't want this behavior, so we are implementing our section headers as cells
      // in the UITableView implementation.
      if let existingSectionHeader = section.sectionHeader {
        items.append(ListInternalTableViewItemStructure(
          listItem: existingSectionHeader,
          dividerType: .sectionHeaderDivider))

        if let dataID = existingSectionHeader.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      section.items.forEach { item in
        items.append(ListInternalTableViewItemStructure(
          listItem: item,
          dividerType: .rowDivider))

        if let dataID = item.dataID {
          itemIndexMap[dataID] = IndexPath(item: itemIndex, section: sectionIndex)
        }

        itemIndex += 1
      }

      if sectionIndex == lastSectionIndex && !items.isEmpty {
        let lastItem = items.removeLast() // Remove last row divider
        items.append(ListInternalTableViewItemStructure(
          listItem: lastItem.listItem,
          dividerType: .none))
      }

      return ListInternalTableViewSectionStructure(
        dataID: section.dataID,
        items: items)
    }

    return ListInternalTableViewStructure(
      sections: sections,
      sectionIndexMap: sectionIndexMap,
      itemIndexMap: itemIndexMap)
  }

  public func makeChangeset(from
    otherStructure: ListInternalTableViewStructure) -> ListInternalTableViewStructureChangeset
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

    return ListInternalTableViewStructureChangeset(
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

    sections[indexPath.section].items[indexPath.item] = ListInternalTableViewItemStructure(
      listItem: item,
      dividerType: oldItem.dividerType)

    return indexPath
  }

}

/// An internal data structure changeset for use in updating a `UITableView`.
public struct ListInternalTableViewStructureChangeset {

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

// MARK: ListInternalTableViewSectionStructure

/// A section in a `ListInternalTableViewStructure`.
public struct ListInternalTableViewSectionStructure {

  init(
    dataID: String,
    items: [ListInternalTableViewItemStructure])
  {
    self.dataID = dataID
    self.items = items
  }

  let dataID: String
  var items: [ListInternalTableViewItemStructure]
}

extension ListInternalTableViewSectionStructure: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? ListInternalTableViewSectionStructure else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String? {
    return dataID
  }
}

// MARK: ListItemDividerType

/// Tells the cell which divider type to use in a view pinned to the cell's bottom.
enum ListItemDividerType {
  case rowDivider
  case sectionHeaderDivider
  case none
}

// MARK: ListInternalTableViewItemStructure

/// An item in a `ListInternalTableViewSectionStructure`, representing either a row or a section header.
public struct ListInternalTableViewItemStructure {

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

extension ListInternalTableViewItemStructure: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableListItem = otherDiffableItem as? ListInternalTableViewItemStructure else { return false }
    return listItem.isDiffableItemEqual(to: otherDiffableListItem.listItem)
  }

  public var diffIdentifier: String? {
    return listItem.diffIdentifier
  }
}
