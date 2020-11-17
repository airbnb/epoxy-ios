// Created by Tyler Hedrick on 5/13/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import EpoxyCore
import Foundation

/// Manages a set of EpoxyModelWrappers for use inside of internal data sources
public final class InternalEpoxySection {
  public init(
    dataID: AnyHashable,
    items: [EpoxyModelWrapper],
    userInfo: [EpoxyUserInfoKey: Any])
  {
    self.dataID = dataID
    self.items = items
    self.userInfo = userInfo
  }

  public let dataID: AnyHashable
  public var userInfo: [EpoxyUserInfoKey: Any]
  public var items: [EpoxyModelWrapper]
}

extension InternalEpoxySection: Diffable {
  public var diffIdentifier: AnyHashable? {
    return dataID
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherItem = otherDiffableItem as? InternalEpoxySection else { return false }
    return otherItem.dataID == dataID
  }
}

extension InternalEpoxySection {
  public var supplementaryModels: [String: [SupplementaryViewEpoxyableModel]] {
    return userInfo[EpoxyUserInfoKey.CollectionView.Section.supplementaryModels] as? [String: [SupplementaryViewEpoxyableModel]] ?? [:]
  }
}

extension InternalEpoxySection: EpoxyableSection {
  public func getCellReuseIDs() -> Set<String> {
    var newCellReuseIDs = Set<String>()
    items.forEach { item in
      newCellReuseIDs.insert(item.reuseID)
    }
    return newCellReuseIDs
  }

  public func getSupplementaryViewReuseIDs() -> [String: Set<String>] {
    var newSupplementaryViewReuseIDs = [String: Set<String>]()
    supplementaryModels.forEach { elementKind, elementSupplementaryModels in
      var newElementSupplementaryViewReuseIDs = Set<String>()
      elementSupplementaryModels.forEach { elementSupplementaryModel in
        newElementSupplementaryViewReuseIDs.insert(elementSupplementaryModel.reuseID)
      }
      newSupplementaryViewReuseIDs[elementKind] = newElementSupplementaryViewReuseIDs
    }
    return newSupplementaryViewReuseIDs
  }

  public var itemModels: [EpoxyableModel] {
    return items
  }
}
