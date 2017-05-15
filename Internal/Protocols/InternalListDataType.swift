//
//  ListInternalDataType.swift
//  List
//
//  Created by Laura Skelton on 4/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

import Foundation

/// Protocol for an internal data type created from an array of `ListSection`s that backs a 
/// particular type of `ListInterface`
public protocol InternalListDataType {

  /// Generates the internal list structure for the specific `ListInterface` type from a general `[ListSection]`
  static func make(with sections: [ListSection]) -> Self

  /// Updates the item at the given `dataID` (if found) with the given updated `ListItem`.
  func updateItem(at dataID: String, with item: ListItem) -> IndexPath?

}

/// Protocol for a diffable internal data type created from an array of `ListSection`s that 
/// backs a particular type of `ListInterface`
public protocol DiffableInternalListDataType: InternalListDataType {

  /// The changeset that represents changes between two instances of this structure
  associatedtype Changeset

  /// The type of list item this structure contains
  associatedtype Item

  /// Makes a changeset between this list data and another list data
  func makeChangeset(from: Self) -> Changeset
  
}
