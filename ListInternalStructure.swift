//  Created by Laura Skelton on 4/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// Protocol for an internal structure created from a `ListStructure` that backs a particular type of `ListInterface`
public protocol ListInternalStructure {

  /// Generates the internal list structure for the specific `ListInterface` type from a general `ListStructure`
  static func make(with listStructure: ListStructure) -> Self

  /// Updates the item at the given `dataID` (if found) with the given updated `ListItem`.
  func updateItem(at dataID: String, with item: ListItem) -> IndexPath?

}

/// Protocol for a diffable internal structure created from a `ListStructure` that backs a particular type of `ListInterface`
public protocol DiffableListInternalStructure: ListInternalStructure {

  /// The changeset that represents changes between two instances of this structure
  associatedtype Changeset

  /// The type of list item this structure contains
  associatedtype Item

  func makeChangeset(from: Self) -> Changeset
  
}
