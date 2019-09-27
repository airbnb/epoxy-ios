// Created by Tyler Hedrick on 5/10/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

// MARK: EpoxyUserInfoKey

public extension EpoxyUserInfoKey {
  enum TableView {
    public enum Row {
      public static var bottomDividerHidden: EpoxyUserInfoKey {
        return EpoxyUserInfoKey(rawValue: "\(TableView.self)_\(#function)")
      }
    }

    public enum Section {
      public static var header: EpoxyUserInfoKey {
        return EpoxyUserInfoKey(rawValue: "\(TableView.self)_\(#function)")
      }
    }
  }
}

// MARK: EpoxyModel

extension BaseEpoxyModelBuilder {
  public func withTableView(bottomDividerHidden: Bool) -> BaseEpoxyModelBuilder {
    return setUserInfoValue(
      bottomDividerHidden,
      for: EpoxyUserInfoKey.TableView.Row.bottomDividerHidden)
  }
}

extension EpoxyableModel {
  /// Only supported in TableView
  public var tableViewBottomDividerHidden: Bool {
    return (userInfo[EpoxyUserInfoKey.TableView.Row.bottomDividerHidden] as? Bool) ?? false
  }
}

// MARK: EpoxySection

extension EpoxySectionBuilder {
  public func withTableView(sectionHeader: EpoxyableModel) -> EpoxySectionBuilder {
    return withSetUserInfoValue(
      sectionHeader,
      for: EpoxyUserInfoKey.TableView.Section.header)
  }
}

extension EpoxySection {
  public var tableViewSectionHeader: EpoxyableModel? {
    return userInfo[EpoxyUserInfoKey.TableView.Section.header] as? EpoxyableModel
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
      updatedUserInfo[EpoxyUserInfoKey.TableView.Section.header] = sectionHeader
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
