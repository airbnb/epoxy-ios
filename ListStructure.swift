//  Created by Laura Skelton on 11/28/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import Foundation

// MARK: ListItemId

/// The `ListItemId` contains the reference id for the model backing an item, as well as the reuse id for the item's type.
public struct ListItemId {

  public init(
    reuseId: String,
    dataId: String)
  {
    self.reuseId = reuseId
    self.dataId = dataId
  }

  /// The `reuseId` corresponding to the item's view type.
  public let reuseId: String

  /// The `dataId` for the model backing the item.
  public let dataId: String
}

// MARK: ListItemStructure

/// The `ListItemStructure` contains the data for an item such as a row or section header.
public struct ListItemStructure {

  public init(
    itemId: ListItemId,
    hashValue: Int? = nil)
  {
    self.itemId = itemId
    self.hashValue = hashValue
  }

  /// The `itemId` contains the reference id for the model backing this item, and the reuse identifier for this item type.
  public let itemId: ListItemId

  /// The optional `hashValue` is used to check for view data equality between items that have the same `itemId` when diffing. If a `hashValue` is not set, the view will always update.
  public let hashValue: Int?
}

extension ListItemStructure: QuickDiffable {
  public func isEqualToDiffableItem(diffableItem: QuickDiffable) -> Bool {
    guard let diffableListItem = diffableItem as? ListItemStructure,
      let lhsHashValue = hashValue,
      let rhsHashValue = diffableListItem.hashValue else { return false }
    return lhsHashValue == rhsHashValue
  }

  public var diffIdentifier: String {
    return itemId.reuseId + "__" + itemId.dataId
  }
}

// MARK: ListSectionStructure

/// The `ListSectionStructure` contains the data for a type of list, such as a TableView.
public struct ListSectionStructure {

  public init(
    dataId: String,
    sectionHeader: ListItemStructure?,
    items: [ListItemStructure])
  {
    self.dataId = dataId
    self.sectionHeader = sectionHeader
    self.items = items
  }

  /// The reference id for the model backing this section.
  public let dataId: String

  /// The data for the section header to be displayed in this section.
  public let sectionHeader: ListItemStructure?

  /// The data for the items to be displayed in this section.
  public let items: [ListItemStructure]
}

extension ListSectionStructure: QuickDiffable {
  public func isEqualToDiffableItem(diffableItem: QuickDiffable) -> Bool {
    guard let diffableSection = diffableItem as? ListSectionStructure else { return false }
    return dataId == diffableSection.dataId
  }

  public var diffIdentifier: String {
    return dataId
  }
}

// MARK: ListStructure

/// The `ListStructure` contains the data for a type of list, such as a TableView.
public struct ListStructure {

  public init(sections: [ListSectionStructure])
  {
    self.sections = sections
  }

  /// Contains the data for a section of a type of list, such as a section of a TableView.
  public let sections: [ListSectionStructure]
}

/// A set of the minimum changes to get from one `ListStructure` to another.
public struct ListStructureChangeset {

  public init(
    sectionChangeset: QuickDiffIndexSetChangeset,
    itemChangeset: QuickDiffIndexPathChangeset)
  {
    self.sectionChangeset = sectionChangeset
    self.itemChangeset = itemChangeset
  }

  /// A set of the minimum changes to get from one set of sections to another.
  public let sectionChangeset: QuickDiffIndexSetChangeset

  /// A set of the minimum changes to get from one set of items to another, aggregated across all sections.
  public let itemChangeset: QuickDiffIndexPathChangeset
}
