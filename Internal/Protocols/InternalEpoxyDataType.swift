//  Created by Laura Skelton on 4/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// Protocol for an internal data type created from an array of `EpoxySection`s that backs a 
/// particular type of `EpoxyInterface`
public protocol InternalEpoxyDataType {

  /// Generates the internal epoxy sections for the specific `EpoxyInterface` type from a general array of `EpoxySection`s
  static func make(with sections: [EpoxySection]) -> Self

  /// Updates the item at the given `dataID` (if found) with the given updated `EpoxyModel`.
  func updateItem(at dataID: String, with item: EpoxyableModel) -> IndexPath?

  func indexPathForItem(at dataID: String) -> IndexPath?

}

/// Protocol for a diffable internal data type created from an array of `EpoxySection`s that 
/// backs a particular type of `EpoxyInterface`
public protocol DiffableInternalEpoxyDataType: InternalEpoxyDataType {

  /// The changeset that represents changes between two arrays of `EpoxySection`s
  associatedtype Changeset

  /// The type of epoxy item this data structure contains
  associatedtype Item

  /// Makes a changeset between this epoxy data and another epoxy data
  func makeChangeset(from otherData: Self) -> Changeset
  
}
