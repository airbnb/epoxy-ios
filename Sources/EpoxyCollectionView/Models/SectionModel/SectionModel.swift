//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import EpoxyCore
import Foundation

// MARK: - SectionModel

/// The `SectionModel` contains the section data for a type of list, such as a `CollectionView`.
public struct SectionModel: EpoxyModeled {

  // MARK: Lifecycle

  public init(dataID: AnyHashable, items: [ItemModeling]) {
    self.dataID = dataID
    self.items = items
  }

  public init(dataID: AnyHashable, @ItemModelBuilder items: () -> [ItemModeling]) {
    self.init(dataID: dataID, items: items())
  }

  // MARK: Public

  public var storage = EpoxyModelStorage()
}

// MARK: DataIDProviding

extension SectionModel: DataIDProviding {}

// MARK: DidEndDisplayingProviding

extension SectionModel: DidEndDisplayingProviding {}

// MARK: ItemsProviding

extension SectionModel: ItemsProviding {}

// MARK: SupplementaryItemsProviding

extension SectionModel: SupplementaryItemsProviding {}

// MARK: WillDisplayProviding

extension SectionModel: WillDisplayProviding {}

// MARK: Diffable

extension SectionModel: Diffable {
  public var diffIdentifier: AnyHashable {
    dataID
  }

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    guard let otherDiffableSection = otherDiffableItem as? Self else { return false }

    // Sections don't have a concept of diffable content, so just compare the data IDs.
    return dataID == otherDiffableSection.dataID
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

// MARK: Deprecations

extension SectionModel {
  @available(
    *,
    deprecated,
    renamed: "init(dataID:items:)",
    message: "SectionModel requires an explicit dataID")
  public init(items: [ItemModeling]) {
    self.items = items
  }

  @available(
    *,
    deprecated,
    renamed: "init(dataID:items:)",
    message: "SectionModel requires an explicit dataID")
  public init(@ItemModelBuilder items: () -> [ItemModeling]) {
    self.items = items()
  }
}
