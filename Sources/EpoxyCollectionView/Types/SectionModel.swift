//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation

/// The `SectionModel` contains the section data for a type of list, such as a `CollectionView`.
public struct SectionModel: EpoxyModeled {

  // MARK: Lifecycle

  public init(dataID: AnyHashable? = nil, items: [ItemModeling]) {
    if let dataID = dataID {
      self.dataID = dataID
    }
    self.items = items
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()
}

// MARK: Providers

extension SectionModel: DataIDProviding {}
extension SectionModel: DidEndDisplayingProviding {}
extension SectionModel: ItemsProviding {}
extension SectionModel: SupplementaryItemsProviding {}
extension SectionModel: WillDisplayProviding {}

// MARK: Diffable

extension SectionModel: Diffable {
  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? Self else { return false }

    // Sections don't have a concept of diffable content, so just compare the data IDs.
    return dataID == otherDiffableSection.dataID
  }

  public var diffIdentifier: AnyHashable {
    dataID
  }
}

// MARK: DiffableSection

extension SectionModel: DiffableSection {
  public var diffableItems: [AnyItemModel] {
    items.map { $0.eraseToAnyItemModel() }
  }
}

// MARK: CallbackContextEpoxyModeled

extension SectionModel: CallbackContextEpoxyModeled {
  /// There's no additional context available on a Section callback as it does not represent a
  /// `UIView`, and instead is just a grouping mechanism.
  public typealias CallbackContext = Void
}
