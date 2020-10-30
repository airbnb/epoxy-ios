//  Created by Bryan Keller on 3/20/18.
//  Copyright © 2018 Airbnb. All rights reserved.

import Foundation

/// A cache for `EpoxyModel`s
///
/// Useful for avoiding unnecessarily recreating `EpoxyModel`s that have not changed
public final class EpoxyModelCache {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func cacheEpoxyModel(_ model: EpoxyableModel) {
    cache.setObject(model as AnyObject, forKey: Key(id: model.dataID))
  }

  public func epoxyModel(forDataID dataID: AnyHashable) -> EpoxyableModel? {
    return cache.object(forKey: Key(id: dataID)) as? EpoxyableModel
  }

  public func invalidateEpoxyModel(withDataID dataID: AnyHashable) {
    cache.removeObject(forKey: Key(id: dataID))
  }

  public func invalidateAllEpoxyModels() {
    cache.removeAllObjects()
  }

  // MARK: Private

  private final class Key: Hashable {
    init(id: AnyHashable) {
      self.id = id
    }

    static func == (lhs: EpoxyModelCache.Key, rhs: EpoxyModelCache.Key) -> Bool {
      lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
      id.hash(into: &hasher)
    }

    var id: AnyHashable
  }

  private let cache = NSCache<Key, AnyObject>()
}
