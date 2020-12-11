//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation

/// The `SectionModel` contains the section data for a type of list, such as a `CollectionView`.
public struct SectionModel: EpoxyModeled {

  // MARK: Lifecycle

  public init(dataID: AnyHashable, items: [ItemModeling]) {
    self.items = items
    self.dataID = dataID
  }

  public init(items: [ItemModeling]) {
    self.init(dataID: "", items: items)
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()
}

// MARK: Providers

extension SectionModel: ItemsProviding {}
extension SectionModel: SupplementaryItemsProviding {}
extension SectionModel: DataIDProviding {}

// MARK: Diffable

extension SectionModel: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? SectionModel else { return false }
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: AnyHashable {
    return dataID
  }
}

// MARK: DiffableSection

extension SectionModel: DiffableSection {
  public var diffableItems: [AnyItemModel] {
    items.map { $0.eraseToAnyItemModel() }
  }
}
