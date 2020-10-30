// Created by Tyler Hedrick on 5/10/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

// MARK: EpoxyUserInfoKey

public extension EpoxyUserInfoKey {
  enum DeprecatedTableView {
    public enum Row {
      public static var bottomDividerHidden: EpoxyUserInfoKey {
        return EpoxyUserInfoKey(rawValue: "\(DeprecatedTableView.self)_\(#function)")
      }
    }

    public enum Section {
      public static var header: EpoxyUserInfoKey {
        return EpoxyUserInfoKey(rawValue: "\(DeprecatedTableView.self)_\(#function)")
      }
    }
  }
}

// MARK: EpoxyModel

extension _BaseEpoxyModelBuilder {
  public func withTableView(bottomDividerHidden: Bool) -> _BaseEpoxyModelBuilder {
    return setUserInfoValue(
      bottomDividerHidden,
      for: EpoxyUserInfoKey.DeprecatedTableView.Row.bottomDividerHidden)
  }
}

extension EpoxyableModel {
  /// Only supported in DeprecatedTableView
  public var tableViewBottomDividerHidden: Bool {
    return (userInfo[EpoxyUserInfoKey.DeprecatedTableView.Row.bottomDividerHidden] as? Bool) ?? false
  }
}

// MARK: EpoxySection

extension EpoxySectionBuilder {
  public func withTableView(sectionHeader: EpoxyableModel) -> EpoxySectionBuilder {
    return withSetUserInfoValue(
      sectionHeader,
      for: EpoxyUserInfoKey.DeprecatedTableView.Section.header)
  }
}

extension EpoxySection {
  public var tableViewSectionHeader: EpoxyableModel? {
    return userInfo[EpoxyUserInfoKey.DeprecatedTableView.Section.header] as? EpoxyableModel
  }
}

extension EpoxySection {
  public init(
    dataID: String,
    sectionHeader: EpoxyableModel?,
    items: [EpoxyableModel],
    userInfo: [EpoxyUserInfoKey: Any] = [:])
  {
    var updatedUserInfo = userInfo
    if let sectionHeader = sectionHeader {
      updatedUserInfo[EpoxyUserInfoKey.DeprecatedTableView.Section.header] = sectionHeader
    }

    self.dataID = dataID
    self.items = items
    self.userInfo = updatedUserInfo
  }

  public init(sectionHeader: EpoxyableModel?, items: [EpoxyableModel]) {
    self.init(
      dataID: "",
      sectionHeader: sectionHeader,
      items: items)
  }
}
