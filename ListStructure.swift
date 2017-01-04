//  Created by Laura Skelton on 11/28/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import Foundation

// MARK: ListItemID

/// The `ListItemID` contains the reference id for the model backing an item, as well as the reuse id for the item's type.
public struct ListItemID {

  public init(
    reuseID: String,
    dataID: String)
  {
    self.reuseID = reuseID
    self.dataID = dataID
  }

  /// The `reuseID` corresponding to the item's view type.
  public let reuseID: String

  /// The `dataID` for the model backing the item.
  public let dataID: String
}

// MARK: ListItemStructure

/// The `ListItemStructure` contains the data for an item such as a row or section header.
public struct ListItemStructure {

  public init(
    itemID: ListItemID,
    hashValue: Int? = nil)
  {
    self.itemID = itemID
    self.hashValue = hashValue
  }

  /// The `itemID` contains the reference id for the model backing this item, and the reuse identifier for this item type.
  public let itemID: ListItemID

  /// The optional `hashValue` is used to check for view data equality between items that have the same `itemID` when diffing. If a `hashValue` is not set, the view will always update.
  public let hashValue: Int?
}

extension ListItemStructure: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableListItem = otherDiffableItem as? ListItemStructure,
      let lhsHashValue = hashValue,
      let rhsHashValue = otherDiffableListItem.hashValue else { return false }
    return lhsHashValue == rhsHashValue
  }

  public var diffIdentifier: String {
    return itemID.reuseID + "__" + itemID.dataID
  }
}

// MARK: ListSectionStructure

/// The `ListSectionStructure` contains the data for a type of list, such as a TableView.
public struct ListSectionStructure {

  public init(
    dataID: String,
    sectionHeader: ListItemStructure?,
    items: [ListItemStructure])
  {
    self.dataID = dataID
    self.sectionHeader = sectionHeader
    self.items = items
  }

  /// The reference id for the model backing this section.
  public let dataID: String

  /// The data for the section header to be displayed in this section.
  public let sectionHeader: ListItemStructure?

  /// The data for the items to be displayed in this section.
  public let items: [ListItemStructure]
}

extension ListSectionStructure: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? ListSectionStructure else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String {
    return dataID
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
    sectionChangeset: IndexSetChangeset,
    itemChangeset: IndexPathChangeset)
  {
    self.sectionChangeset = sectionChangeset
    self.itemChangeset = itemChangeset
  }

  /// A set of the minimum changes to get from one set of sections to another.
  public let sectionChangeset: IndexSetChangeset

  /// A set of the minimum changes to get from one set of items to another, aggregated across all sections.
  public let itemChangeset: IndexPathChangeset
}
