//  Created by Laura Skelton on 12/4/16.
//  Copyright © 2016 com.airbnb. All rights reserved.

import Foundation

// MARK: ListInternalTableViewStructure

/// An internal data structure constructed from a `ListStructure` that is specific
/// to display in a `UITableView` implementation.
struct ListInternalTableViewStructure {

  init(sections: [ListInternalTableViewSectionStructure])
  {
    self.sections = sections
  }

  let sections: [ListInternalTableViewSectionStructure]
}

extension ListInternalTableViewStructure {

  static func makeWithListStructure(listStructure: ListStructure) -> ListInternalTableViewStructure {

    let lastSectionIndex = listStructure.sections.count - 1
    let sections: [ListInternalTableViewSectionStructure] = listStructure.sections.enumerate().map { index, section in

      var items = [ListInternalTableViewItemStructure]()

      // Note: Default UITableView section headers are "sticky" at the top of the page.
      // We don't want this behavior, so we are implementing our section headers as cells
      // in the UITableView implementation.
      if let existingSectionHeader = section.sectionHeader {
        items.append(ListInternalTableViewItemStructure(
          listItem: existingSectionHeader,
          dividerType: .SectionHeaderDivider))
      }

      section.items.forEach { item in
        items.append(ListInternalTableViewItemStructure(
          listItem: item,
          dividerType: .RowDivider))
      }

      if index == lastSectionIndex {
        let lastItem = items.removeLast() // Remove last row divider
        items.append(ListInternalTableViewItemStructure(
          listItem: lastItem.listItem,
          dividerType: .None))
      }

      return ListInternalTableViewSectionStructure(
        dataId: section.dataId,
        items: items)
    }

    return ListInternalTableViewStructure(sections: sections)
  }

  static func diff(oldStructure
    oldStructure: ListInternalTableViewStructure,
    newStructure: ListInternalTableViewStructure) -> ListInternalTableViewStructureChangeset
  {
    let sectionChangeset = QuickDiff.diffIndexSets(
      oldArray: oldStructure.sections,
      newArray: newStructure.sections)

    var itemChangesetsForSections = [QuickDiffIndexPathChangeset]()
    for i in 0..<oldStructure.sections.count {
      if let newSectionIndex = sectionChangeset.newIndices[i] {

        let fromSection = i
        let toSection = newSectionIndex

        let fromArray = oldStructure.sections[fromSection].items
        let toArray = newStructure.sections[toSection].items

        let itemIndexChangeset = QuickDiff.diffIndexPaths(
          oldArray: fromArray,
          newArray: toArray,
          fromSection: fromSection,
          toSection: toSection)

        itemChangesetsForSections.append(itemIndexChangeset)
      }
    }

    let itemChangeset: QuickDiffIndexPathChangeset = itemChangesetsForSections.reduce(QuickDiffIndexPathChangeset()) { masterChangeset, thisChangeset in

      let inserts: [NSIndexPath] = masterChangeset.inserts + thisChangeset.inserts
      let deletes: [NSIndexPath] = masterChangeset.deletes + thisChangeset.deletes
      let updates: [(NSIndexPath, NSIndexPath)] = masterChangeset.updates + thisChangeset.updates
      let moves: [(NSIndexPath, NSIndexPath)] = masterChangeset.moves + thisChangeset.moves

      return QuickDiffIndexPathChangeset(
        inserts: inserts,
        deletes: deletes,
        updates: updates,
        moves: moves)
    }

    return ListInternalTableViewStructureChangeset(
      sectionChangeset: sectionChangeset,
      itemChangeset: itemChangeset)
  }
}

/// An internal data structure changeset for use in updating a `UITableView`.
struct ListInternalTableViewStructureChangeset {

  init(
    sectionChangeset: QuickDiffIndexSetChangeset,
    itemChangeset: QuickDiffIndexPathChangeset)
  {
    self.sectionChangeset = sectionChangeset
    self.itemChangeset = itemChangeset
  }

  let sectionChangeset: QuickDiffIndexSetChangeset
  let itemChangeset: QuickDiffIndexPathChangeset
}

// MARK: ListInternalTableViewSectionStructure

/// A section in a `ListInternalTableViewStructure`.
struct ListInternalTableViewSectionStructure {

  init(
    dataId: String,
    items: [ListInternalTableViewItemStructure])
  {
    self.dataId = dataId
    self.items = items
  }

  let dataId: String
  let items: [ListInternalTableViewItemStructure]
}

extension ListInternalTableViewSectionStructure: QuickDiffable {
  func isEqualToDiffableItem(diffableItem: QuickDiffable) -> Bool {
    guard let diffableSection = diffableItem as? ListInternalTableViewSectionStructure else { return false }
    return dataId == diffableSection.dataId
  }

  var diffIdentifier: String {
    return dataId
  }
}

// MARK: ListItemDividerType

/// Tells the cell which divider type to use in a view pinned to the cell's bottom.
enum ListItemDividerType {
  case RowDivider
  case SectionHeaderDivider
  case None
}

// MARK: ListInternalTableViewItemStructure

/// An item in a `ListInternalTableViewSectionStructure`, representing either a row or a section header.
struct ListInternalTableViewItemStructure {

  init(
    listItem: ListItemStructure,
    dividerType: ListItemDividerType)
  {
    self.listItem = listItem
    self.dividerType = dividerType
  }

  let listItem: ListItemStructure
  let dividerType: ListItemDividerType
}

extension ListInternalTableViewItemStructure: QuickDiffable {
  func isEqualToDiffableItem(diffableItem: QuickDiffable) -> Bool {
    guard let diffableListItem = diffableItem as? ListInternalTableViewItemStructure else { return false }
    return listItem.isEqualToDiffableItem(diffableListItem.listItem)
  }

  var diffIdentifier: String {
    return listItem.diffIdentifier
  }
}
