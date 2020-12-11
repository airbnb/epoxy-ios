// Created by eric_horacek on 12/8/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation

/// A path to a specific item within a section in a `CollectionView`.
public struct ItemPath: Hashable {

  // MARK: Lifecycle

  public init(itemDataID: AnyHashable, sectionDataID: AnyHashable?) {
    self.itemDataID = itemDataID
    self.sectionDataID = sectionDataID
  }

  // MARK: Public

  /// The identifier that uniquely identifies an item within its section.
  public let itemDataID: AnyHashable

  /// The identifier that uniquely identifies a section within all sections of a collection.
  ///
  /// If `nil`, this path refers to the first item with `itemDataID` as its `dataID` in any section.
  /// If there are multiple sections with an items that share the same `dataID`, it is not
  /// recommended to have this property as `nil`, as the located item may be unstable over time
  ///
  /// Set this to `nil` only if you are certain that you will not have duplicate `itemDataID`s
  /// across sections, e.g. if there is only ever one section in your collection.
  public let sectionDataID: AnyHashable?

  /// Constructs an `ItemPath` for the last section that has an item that has the given data ID.
  public static func lastSectionWith(itemDataID: AnyHashable) -> ItemPath {
    .init(itemDataID: itemDataID, sectionDataID: nil)
  }

}
