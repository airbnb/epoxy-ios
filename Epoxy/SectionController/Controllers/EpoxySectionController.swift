//  Created by Laura Skelton on 3/21/18.
//  Copyright © 2018 Airbnb. All rights reserved.

// MARK: - EpoxySectionControllerStringID

/// An ID that can be used with a EpoxySectionController<String>.
public struct EpoxySectionControllerStringID: RawRepresentable, Hashable {
  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public let rawValue: String
}

// MARK: - EpoxySectionController

open class EpoxySectionController<ItemDataIDType>: EpoxySectionControlling
  where
  ItemDataIDType: Hashable,
  ItemDataIDType: RawRepresentable,
  ItemDataIDType.RawValue == String
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

  open func makeSection() -> EpoxySection {
    return EpoxySection(
      dataID: dataID,
      items: allItemModels())
  }

  open func hiddenDividers() -> [ItemDataIDType] {
    return []
  }

  /// You probably want to override hiddenDividers() instead
  open func hiddenDividerDataIDs() -> [AnyHashable] {
    hiddenDividers().compactMap(convertDataID)
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
    modelCache.invalidateEpoxyModel(withDataID: convertDataID(dataID))
    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func rebuildItemModels(forDataIDs dataIDs: [ItemDataIDType], animated: Bool = true) {
    for dataID in dataIDs {
      modelCache.invalidateEpoxyModel(withDataID: convertDataID(dataID))
    }

    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func invalidateEpoxyModel(withDataID dataID: String) {
    modelCache.invalidateEpoxyModel(withDataID: dataID)
  }

  public func invalidateAllEpoxyModels() {
    modelCache.invalidateAllEpoxyModels()
  }

  public func rebuild(animated: Bool = true) {
    modelCache.invalidateAllEpoxyModels()
    delegate?.epoxyControllerDidUpdateData(self, animated: animated)
  }

  public func makeSections() -> [EpoxySection] {
    return [makeSection()]
  }

  // MARK: Private

  private let modelCache = EpoxyModelCache()
  private let invalidatesRemovedModelsFromCache: Bool

  private func convertDataID(_ dataID: ItemDataIDType) -> AnyHashable {
    // If the dividers are RawRepresentable, use the string values in since that's what consumers
    // are expecting.
    dataID.rawValue
  }

  private func cachedItemModel(forDataID dataID: ItemDataIDType) -> EpoxyableModel? {
    if let existingItemModel = modelCache.epoxyModel(forDataID: dataID) {
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
        modelCache.invalidateEpoxyModel(withDataID: itemDataID)
      }
    }
  }
}
