// Created by eric_horacek on 12/8/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation

/// A path to a specific item within a section in a `CollectionView`.
public struct ItemPath: Hashable {

  // MARK: Lifecycle

  public init(itemDataID: AnyHashable, section: Section) {
    self.itemDataID = itemDataID
    self.section = section
  }

  // MARK: Public

  /// The section in which the item referenced by an `ItemPath` is located.
  public enum Section: Hashable {
    /// The section identified by the `dataID` on its corresponding `SectionModel`.
    case dataID(AnyHashable)

    /// The last section that contains an item with `itemDataID` as its `dataID`.
    ///
    /// If there are multiple sections with an items that have the same `dataID`, it is not
    /// recommended use this case, as the located item may be unstable over time.
    case lastWithItemDataID
  }

  /// The item identified by the `dataID` on its corresponding `ItemModel`.
  public var itemDataID: AnyHashable

  /// The section in which the item referenced by this path located.
  public var section: Section

}
