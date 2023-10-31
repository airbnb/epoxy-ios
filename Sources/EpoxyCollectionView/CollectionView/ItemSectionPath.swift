// Created by Bryn Bodayle on 8/15/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Foundation

/// The section in which an item referenced by an `ItemPath` or `SupplementaryItemPath` is located.
public enum ItemSectionPath: Hashable {
  /// The section identified by the `dataID` on its corresponding `SectionModel`.
  case dataID(AnyHashable)

  /// The last section that contains an item with `itemDataID` as its `dataID`.
  ///
  /// If there are multiple sections with items that have the same `dataID`, it is not
  /// recommended to use this case, as the located item may be unstable over time.
  case lastWithItemDataID
}
