// Created by eric_horacek on 12/8/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation

/// A path to a specific item within a section in a `CollectionView`.
public struct ItemPath: Hashable {

  // MARK: Lifecycle

  public init(itemDataID: AnyHashable, section: ItemSectionPath) {
    self.itemDataID = itemDataID
    self.section = section
  }

  // MARK: Public

  /// The item identified by the `dataID` on its corresponding `ItemModel`.
  public var itemDataID: AnyHashable

  /// The section in which the item referenced by this path located.
  public var section: ItemSectionPath

}
