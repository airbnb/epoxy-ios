//  Created by Laura Skelton on 11/28/16.
//  Copyright © 2016 Airbnb. All rights reserved.

import Foundation

// MARK: ListSectionStructure

/// The `ListSectionStructure` contains the data for a type of list, such as a TableView.
public struct ListSectionStructure {

  public init(
    dataID: String,
    sectionHeader: ListItem?,
    items: [ListItem])
  {
    self.dataID = dataID
    self.sectionHeader = sectionHeader
    self.items = items
  }

  /// The reference id for the model backing this section.
  public let dataID: String

  /// The data for the section header to be displayed in this section.
  public let sectionHeader: ListItem?

  /// The data for the items to be displayed in this section.
  public let items: [ListItem]
}

extension ListSectionStructure: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? ListSectionStructure else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String? {
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

  public init(items: [ListItem])
  {
    let section = ListSectionStructure(
      dataID: "",
      sectionHeader: nil,
      items: items)
    self.init(sections: [section])
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
