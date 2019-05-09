// Created by Tyler Hedrick on 5/6/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

/// Builder that can be used to create EpoxySections
/// efficiently over time.
public final class EpoxyTableViewSectionBuilder {

  public init(dataID: String, items: [EpoxyableModel] = []) {
    self.dataID = dataID
    self.items = items
  }

  // MARK: Public

  /// Builds the section from the current set of data.
  public func build() -> EpoxySection {
    return EpoxySection(
      dataID: dataID,
      sectionHeader: sectionHeader,
      items: items,
      userInfo: userInfo)
  }

  /// Sets the provided `EpoxyableModel` as the section header of the built section
  public func with(sectionHeader: EpoxyableModel) -> EpoxyTableViewSectionBuilder {
    self.sectionHeader = sectionHeader
    return self
  }

  /// Sets the items array on the builder. This will override the current set of items
  /// and any items you've added through `.with(appendedItem:)` or `.with(appendedItems:)`
  public func with(items: [EpoxyableModel]) -> EpoxyTableViewSectionBuilder {
    self.items = items
    return self
  }

  /// Appends an array of items to the end of the internal set of items
  public func with(appendedItems: [EpoxyableModel]) -> EpoxyTableViewSectionBuilder {
    self.items.append(contentsOf: appendedItems)
    return self
  }

  /// Appends an item to the internal set of items
  public func with(appendedItem item: EpoxyableModel) -> EpoxyTableViewSectionBuilder {
    items.append(item)
    return self
  }

  /// Inserts an item to the specified index in the internal set of items
  public func with(item: EpoxyableModel, insertedAt index: Int) -> EpoxyTableViewSectionBuilder {
    items.insert(item, at: index)
    return self
  }

  /// Fully sets the userInfo dictionary and overrides the old one
  public func with(userInfo: [EpoxyUserInfoKey: Any]) -> EpoxyTableViewSectionBuilder {
    self.userInfo = userInfo
    return self
  }

  /// Sets a key in the userInfo dictionary to the provided value
  public func withSetUserInfoValue(_ value: Any, for key: EpoxyUserInfoKey) -> EpoxyTableViewSectionBuilder {
    userInfo[key] = value
    return self
  }

  // MARK: Private

  private let dataID: String
  private var sectionHeader: EpoxyableModel? = nil
  private var items: [EpoxyableModel]
  private var userInfo: [EpoxyUserInfoKey: Any] = [:]
}

// MARK: Subscript

extension EpoxyTableViewSectionBuilder {
  /// provides a subscript interface to set and get values from the userInfo
  /// dictionary on a builder
  /// example usage: `builder[EpoxyUserInfoKey.customKey] = customValue`
  public subscript<T>(key: EpoxyUserInfoKey) -> T? {
    get { return userInfo[key] as? T }
    set { userInfo[key] = newValue }
  }
}
