//  Created by Laura Skelton on 4/6/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import Foundation

/// Protocol for an internal data type created from an array of `EpoxySection`s that backs a 
/// particular type of `EpoxyInterface`
public protocol InternalEpoxyDataType {

  /// The type of item in this data type
  associatedtype Item

  /// The type of section this data structure contains
  associatedtype InternalSection: EpoxyableSection

  /// The type of epoxy data sections used to generate this internal data type. In almost all cases
  /// this is just `EpoxySection`.
  associatedtype ExternalSection: EpoxyableSection

  /// Generates the internal epoxy sections for the specific `EpoxyInterface` type from a general array of `ExternalSection`s
  static func make(with sections: [ExternalSection]) -> Self

  /// Updates the item at the given `dataID` (if found) with the given updated `EpoxyModel`.
  func updateItem(at dataID: String, with item: EpoxyableModel) -> IndexPath?

  func indexPathForItem(at dataID: String) -> IndexPath?

  /// Makes a changeset between this epoxy data and another epoxy data
  func makeChangeset(from otherData: Self) -> EpoxyChangeset

  /// The sections array of this data type
  var sections: [InternalSection] { get }
}
