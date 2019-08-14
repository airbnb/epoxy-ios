//  Created by Bryan Keller on 3/20/18.
//  Copyright © 2018 Airbnb. All rights reserved.

import Foundation

/// A cache for `EpoxyModel`s
///
/// Useful for avoiding unnecessarily recreating `EpoxyModel`s that have not changed
public final class EpoxyModelCache {

  // MARK: Lifecycle

  public init() { }

  deinit {
    invalidateAllEpoxyModels()
  }

  // MARK: Public

  public func cacheEpoxyModel(_ model: EpoxyableModel) {
    cache.setObject(model as AnyObject, forKey: cacheKey(forDataID: model.dataID))
  }

  public func epoxyModel(forDataID dataID: String) -> EpoxyableModel? {
    return cache.object(forKey: cacheKey(forDataID: dataID)) as? EpoxyableModel
  }

  public func invalidateEpoxyModel(withDataID dataID: String) {
    cache.removeObject(forKey: cacheKey(forDataID: dataID))
  }

  public func invalidateAllEpoxyModels() {
    cache.removeAllObjects()
  }

  // MARK: Private

  private let cache = NSCache<NSString, AnyObject>()

  private func cacheKey(forDataID dataID: String) -> NSString {
    return NSString(string: dataID)
  }
}
