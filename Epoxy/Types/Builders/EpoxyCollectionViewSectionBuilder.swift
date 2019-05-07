// Created by Tyler Hedrick on 5/6/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

/// Builder that can be used to create EpoxyCollectionViewSections
/// efficiently over time.
public final class EpoxyCollectionViewSectionBuilder {

  public init(dataID: String, items: [EpoxyableModel] = []) {
    self.dataID = dataID
    self.items = items
  }

  // MARK: Public

  /// Builds the section from the current set of data.
  public func build() -> EpoxyCollectionViewSection {
    return EpoxyCollectionViewSection(
      dataID: dataID,
      items: items,
      supplementaryModels: supplementaryModels,
      userInfo: userInfo)
  }

  /// Sets the items array on the builder. This will override the current set of items
  /// and any items you've added through `.with(appendedItem:)` or `.with(appendedItems:)`
  public func with(items: [EpoxyableModel]) -> EpoxyCollectionViewSectionBuilder {
    self.items = items
    return self
  }

  /// Appends an array of items to the end of the internal set of items
  public func with(appendedItems: [EpoxyableModel]) -> EpoxyCollectionViewSectionBuilder {
    self.items.append(contentsOf: appendedItems)
    return self
  }

  /// Appends an item to the internal set of items
  public func with(appendedItem item: EpoxyableModel) -> EpoxyCollectionViewSectionBuilder {
    items.append(item)
    return self
  }

  /// Inserts an item to the specified index in the internal set of items
  public func with(item: EpoxyableModel, insertedAt index: Int) -> EpoxyCollectionViewSectionBuilder {
    items.insert(item, at: index)
    return self
  }

  /// Adds an array of supplementary models for the given identifier
  public func withSetSupplementaryModels(
    _ supplementaryModels: [SupplementaryViewEpoxyableModel],
    for identifier: String)
    -> EpoxyCollectionViewSectionBuilder
  {
    if self.supplementaryModels == nil {
      self.supplementaryModels = [:]
    }
    self.supplementaryModels?[identifier] = supplementaryModels
    return self
  }

  /// Fully sets the supplementary model mapping and overrides the old one
  public func with(supplementaryModels: [String: [SupplementaryViewEpoxyableModel]]) -> EpoxyCollectionViewSectionBuilder {
    self.supplementaryModels = supplementaryModels
    return self
  }

  /// Fully sets the userInfo dictionary and overrides the old one
  public func with(userInfo: [EpoxyUserInfoKey: Any]) -> EpoxyCollectionViewSectionBuilder {
    self.userInfo = userInfo
    return self
  }

  /// Sets a key in the userInfo dictionary to the provided value
  public func withSetUserInfoValue(_ value: Any, for key: EpoxyUserInfoKey) -> EpoxyCollectionViewSectionBuilder {
    userInfo[key] = value
    return self
  }

  // MARK: Private

  private let dataID: String
  private var items: [EpoxyableModel]
  private var supplementaryModels: [String: [SupplementaryViewEpoxyableModel]]? = nil
  private var userInfo: [EpoxyUserInfoKey: Any] = [:]
}
