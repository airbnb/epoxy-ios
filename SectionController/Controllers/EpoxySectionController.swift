//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

open class EpoxySectionController<ItemDataIDType>: EpoxySectionControlling
  where
  ItemDataIDType: StringRepresentable,
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

  open func hiddenDividerDataIDs() -> [String] {
    return []
  }

  // MARK: Public

  public weak var navigator: EpoxyNavigable?

  public weak var delegate: EpoxyControllerDelegate? {
    didSet { delegate?.epoxyControllerDidUpdateData(self) }
  }

  public var itemDataIDs = [ItemDataIDType]() {
    didSet { didUpdateItemDataIDs(oldValue) }
  }

  public func allItemModels() -> [EpoxyableModel] {
    return itemDataIDs.flatMap { dataID in
      cachedItemModel(forDataID: dataID)
    }
  }

  public func rebuildItemModel(forDataID dataID: ItemDataIDType) {
    modelCache.invalidateEpoxyModel(withDataID: dataID.stringValue)
    delegate?.epoxyControllerDidUpdateData(self)
  }

  public func rebuild() {
    modelCache.invalidateAllEpoxyModels()
    delegate?.epoxyControllerDidUpdateData(self)
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

  private func didUpdateItemDataIDs(_ oldDataIDs: [ItemDataIDType]) {
    if invalidatesRemovedModelsFromCache {
      removeOldCachedValues(oldDataIDs)
    }
    delegate?.epoxyControllerDidUpdateData(self)
  }

  private func cachedItemModel(forDataID dataID: ItemDataIDType) -> EpoxyableModel? {
    if let existingItemModel = modelCache.epoxyModel(forDataID: dataID.stringValue) {
      return existingItemModel
    }

    guard let newItemModel = itemModel(forDataID: dataID) else {
      return nil
    }
    newItemModel.dataID = dataID.stringValue

    modelCache.cacheEpoxyModel(newItemModel)

    return newItemModel
  }

  private func removeOldCachedValues(_ oldDataIDs: [ItemDataIDType]) {
    oldDataIDs.forEach { itemDataID in
      if !itemDataIDs.contains(itemDataID) {
        modelCache.invalidateEpoxyModel(withDataID: itemDataID.stringValue)
      }
    }
  }
}
