//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation

/// The `EpoxySection` contains the section data for a type of list, such as a `CollectionView`.
public struct EpoxySection: EpoxyModeled, EpoxyableSection {

  // MARK: Lifecycle

  public init(dataID: AnyHashable, items: [EpoxyableModel]) {
    self.items = items
    self.dataID = dataID
  }

  public init(items: [EpoxyableModel]) {
    self.init(dataID: "", items: items)
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()
}

// MARK: Diffable

extension EpoxySection: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? EpoxySection else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: AnyHashable {
    return dataID
  }
}
