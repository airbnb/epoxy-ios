//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

open class EpoxySectionController<ItemDataIDType>: EpoxySectionControlling
  where
  ItemDataIDType: EpoxyStringRepresentable,
  ItemDataIDType: Hashable
{

  // MARK: Lifecycle

  public init(invalidatesRemovedModelsFromCache: Bool = true) {
    self.invalidatesRemovedModelsFromCache = invalidatesRemovedModelsFromCache
  }

  // MARK: Open

  open var dataID: String = ""

  open func itemModel(forDataID dataID: ItemDataIDType) -> EpoxyableModel? {
    return nil
  }

  open func makeTableViewSection() -> EpoxySection {
    return EpoxySection(
      dataID: dataID,
      sectionHeader: nil,
      items: allItemModels())
  }

  open func makeCollectionViewSection() -> EpoxyCollectionViewSection {
    return EpoxyCollectionViewSection(
      dataID: dataID,
      items: allItemModels(),
      supplementaryModels: nil)
  }

  open func hiddenDividers() -> [ItemDataIDType] {
    return []
  }

  /// You probably want to override hiddenDividers() instead
  open func hiddenDividerDataIDs() -> [String] {
    return hiddenDividers().map { $0.epoxyStringValue }
  }

  // MARK: Public

  open weak var interface: EpoxyInterface?

  public weak var delegate: EpoxyControllerDelegate? {
    didSet { delegate?.epoxyControllerDidUpdateData(self, animated: true) }
  }

  public private(set) var itemDataIDs = [ItemDataIDType]()

  public func setDataIDsAndUpdate(_ newDataIDs: [ItemDataIDType], animated: Bool = true) {
    setDataIDs(newDataIDs)
    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func setDataIDs(_ newDataIDs: [ItemDataIDType]) {
    let oldValue = itemDataIDs
    itemDataIDs = newDataIDs
    if invalidatesRemovedModelsFromCache {
      removeOldCachedValues(oldValue)
    }
  }

  public func allItemModels() -> [EpoxyableModel] {
    return itemDataIDs.compactMap { dataID in
      cachedItemModel(forDataID: dataID)
    }
  }

  public func rebuildItemModel(forDataID dataID: ItemDataIDType, animated: Bool = true) {
    modelCache.invalidateEpoxyModel(withDataID: dataID.epoxyStringValue)
    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func rebuildItemModels(forDataIDs dataIDs: [ItemDataIDType], animated: Bool = true) {
    for dataID in dataIDs {
      modelCache.invalidateEpoxyModel(withDataID: dataID.epoxyStringValue)
    }

    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func invalidateEpoxyModel(withDataID dataID: String) {
    modelCache.invalidateEpoxyModel(withDataID: dataID.epoxyStringValue)
  }

  public func rebuild(animated: Bool = true) {
    modelCache.invalidateAllEpoxyModels()
    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func makeTableViewSections() -> [EpoxySection] {
    return [makeTableViewSection()]
  }

  public func makeCollectionViewSections() -> [EpoxyCollectionViewSection] {
    return [makeCollectionViewSection()]
  }

  // MARK: Private

  private let modelCache = EpoxyModelCache()
  private let invalidatesRemovedModelsFromCache: Bool

  private func cachedItemModel(forDataID dataID: ItemDataIDType) -> EpoxyableModel? {
    if let existingItemModel = modelCache.epoxyModel(forDataID: dataID.epoxyStringValue) {
      return existingItemModel
    }

    guard let newItemModel = itemModel(forDataID: dataID) else {
      return nil
    }

    modelCache.cacheEpoxyModel(newItemModel)

    return newItemModel
  }

  private func removeOldCachedValues(_ oldDataIDs: [ItemDataIDType]) {
    oldDataIDs.forEach { itemDataID in
      if !itemDataIDs.contains(itemDataID) {
        modelCache.invalidateEpoxyModel(withDataID: itemDataID.epoxyStringValue)
      }
    }
  }
}
