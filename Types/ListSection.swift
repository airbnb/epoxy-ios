//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// The `ListSection` contains the section data for a type of list, such as a TableView.
public struct ListSection {

  // MARK: Lifecycle

  public init(
    dataID: String,
    sectionHeader: ListItem?,
    items: [ListItem])
  {
    self.dataID = dataID
    self.sectionHeader = sectionHeader
    self.items = items
  }

  public init(
    sectionHeader: ListItem?,
    items: [ListItem])
  {
    self.init(
      dataID: "",
      sectionHeader: sectionHeader,
      items: items)
  }

  public init(items: [ListItem]) {
    self.init(
      dataID: "",
      sectionHeader: nil,
      items: items)
  }

  // MARK: Public

  /// The reference id for the model backing this section.
  public let dataID: String

  /// The data for the section header to be displayed in this section.
  public let sectionHeader: ListItem?

  /// The data for the items to be displayed in this section.
  public let items: [ListItem]
}

// MARK: Diffable

extension ListSection: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? ListSection else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: String? {
    return dataID
  }
}
