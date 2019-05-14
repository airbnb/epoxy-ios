// Created by Tyler Hedrick on 5/6/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

/// Builder that can be used to create EpoxySections
/// efficiently over time.
public final class EpoxySectionBuilder {

  public init(dataID: String, items: [EpoxyableModel] = []) {
    self.dataID = dataID
    self.items = items
  }

  // MARK: Public

  /// Builds the section from the current set of data.
  public func build() -> EpoxySection {
    return EpoxySection(
      dataID: dataID,
      items: items,
      userInfo: userInfo)
  }

  /// Sets the items array on the builder. This will override the current set of items
  /// and any items you've added through `.with(appendedItem:)` or `.with(appendedItems:)`
  public func with(items: [EpoxyableModel]) -> EpoxySectionBuilder {
    self.items = items
    return self
  }

  /// Appends an array of items to the end of the internal set of items
  public func with(appendedItems: [EpoxyableModel]) -> EpoxySectionBuilder {
    self.items.append(contentsOf: appendedItems)
    return self
  }

  /// Appends an item to the internal set of items
  public func with(appendedItem item: EpoxyableModel) -> EpoxySectionBuilder {
    items.append(item)
    return self
  }

  /// Inserts an item to the specified index in the internal set of items
  public func with(item: EpoxyableModel, insertedAt index: Int) -> EpoxySectionBuilder {
    items.insert(item, at: index)
    return self
  }

  /// Fully sets the userInfo dictionary and overrides the old one
  public func with(userInfo: [EpoxyUserInfoKey: Any]) -> EpoxySectionBuilder {
    self.userInfo = userInfo
    return self
  }

  /// Sets a key in the userInfo dictionary to the provided value
  public func withSetUserInfoValue(_ value: Any, for key: EpoxyUserInfoKey) -> EpoxySectionBuilder {
    userInfo[key] = value
    return self
  }

  // MARK: Private

  private let dataID: String
  private var items: [EpoxyableModel]
  private var userInfo: [EpoxyUserInfoKey: Any] = [:]
}

// MARK: Subscript

extension EpoxySectionBuilder {
  /// provides a subscript interface to set and get values from the userInfo
  /// dictionary on a builder
  /// example usage: `builder[EpoxyUserInfoKey.customKey] = customValue`
  public subscript<T>(key: EpoxyUserInfoKey) -> T? {
    get { return userInfo[key] as? T }
    set { userInfo[key] = newValue }
  }
}
