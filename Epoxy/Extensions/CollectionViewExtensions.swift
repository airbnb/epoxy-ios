// Created by Tyler Hedrick on 5/10/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

// MARK: EpoxyUserInfoKey

public extension EpoxyUserInfoKey {
  enum CollectionView {
    public enum Section {
      public static var supplementaryModels: EpoxyUserInfoKey {
        return EpoxyUserInfoKey(rawValue: "\(CollectionView.self)_\(#function)")
      }
    }
  }
}

// MARK: EpoxySection

extension EpoxySectionBuilder {
  public func withCollectionView(supplementaryModels: [String: [SupplementaryViewEpoxyableModel]]) -> EpoxySectionBuilder {
    return withSetUserInfoValue(
      supplementaryModels,
      for: EpoxyUserInfoKey.CollectionView.Section.supplementaryModels)
  }
}

extension EpoxySection {
  public var collectionViewSupplementaryModels: [String: [SupplementaryViewEpoxyableModel]]? {
    return userInfo[EpoxyUserInfoKey.CollectionView.Section.supplementaryModels] as? [String: [SupplementaryViewEpoxyableModel]]
  }
}

extension EpoxySection {
  public init(
    dataID: String = "",
    items: [EpoxyableModel],
    supplementaryModels: [String: [SupplementaryViewEpoxyableModel]]? = nil,
    userInfo: [EpoxyUserInfoKey: Any] = [:])
  {
    var updatedUserInfo = userInfo
    if let supplementaryModels = supplementaryModels {
      updatedUserInfo[EpoxyUserInfoKey.CollectionView.Section.supplementaryModels] = supplementaryModels
    }

    self.dataID = dataID
    self.items = items
    self.userInfo = updatedUserInfo
  }
}
