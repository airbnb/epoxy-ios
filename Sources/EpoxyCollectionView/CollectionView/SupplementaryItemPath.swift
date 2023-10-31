// Created by Bryn Bodayle on 8/15/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Foundation

/// A path to a specific supplementary item within a section in a `CollectionView`.
public struct SupplementaryItemPath: Hashable {

  // MARK: Lifecycle

  public init(elementKind: String, itemDataID: AnyHashable, section: ItemSectionPath) {
    self.elementKind = elementKind
    self.itemDataID = itemDataID
    self.section = section
  }

  // MARK: Public

  /// The type of supplementary view
  public var elementKind: String

  /// The supplementary item identified by the `dataID` on its corresponding `ItemModel`.
  public var itemDataID: AnyHashable

  /// The section in which the supplementary item referenced by this path located.
  public var section: ItemSectionPath

}
