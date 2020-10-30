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
    cache.setObject(model as AnyObject, forKey: Key(model.dataID))
  }

  public func epoxyModel(forDataID dataID: AnyHashable) -> EpoxyableModel? {
    return cache.object(forKey: Key(dataID)) as? EpoxyableModel
  }

  public func invalidateEpoxyModel(withDataID dataID: AnyHashable) {
    cache.removeObject(forKey: Key(dataID))
  }

  public func invalidateAllEpoxyModels() {
    cache.removeAllObjects()
  }

  // MARK: Private

  private class Key: NSObject {

    init(_ key: AnyHashable) {
      self.key = key
    }

    override var hash: Int {
      key.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
      guard let other = object as? Key else { return false }
      return key == other.key
    }

    let key: AnyHashable
  }

  private let cache = NSCache<Key, AnyObject>()
}
