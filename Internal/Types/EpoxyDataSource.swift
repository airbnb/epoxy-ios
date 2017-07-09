//  Created by Laura Skelton on 5/11/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

/// A data source powered by an array of `EpoxySection`s that can be specialized for different types of `EpoxyInterface`s
public class EpoxyDataSource<EpoxyInterfaceType: InternalEpoxyInterface>: NSObject {

  // MARK: Lifecycle

  override init() {
    super.init()
  }

  // MARK: Internal

  weak var epoxyInterface: EpoxyInterfaceType? {
    didSet {
      resetReuseIDs()
    }
  }

  private(set) var internalData: EpoxyInterfaceType.DataType?

  func setSections(_ sections: [EpoxySection]?, animated: Bool) {
    assert(Thread.isMainThread, "This method must be called on the main thread.")
    registerReuseIDs(with: sections)
    var newInternalData: EpoxyInterfaceType.DataType? = nil
    if let sections = sections {
      newInternalData = EpoxyInterfaceType.DataType.make(with: sections)
    }

    applyData(newInternalData: newInternalData, animated: animated)
  }

  func updateItem(
    at dataID: String,
    with item: EpoxyableModel,
    animated: Bool)
  {
    guard let internalData = internalData else {
      assertionFailure("Update item was called when the data was nil.")
      return
    }
    guard let epoxyInterface = epoxyInterface else {
      assertionFailure("Update item was called before the EpoxyInterface was set.")
      return
    }
    guard let indexPath = internalData.updateItem(at: dataID, with: item) else {
      assertionFailure("Update item was called with an index path that does not exist in the data.")
      return
    }

    epoxyInterface.reloadItem(at: indexPath, animated: animated)
  }

  // MARK: Private

  private var reuseIDs = Set<String>()

  private func applyData(newInternalData: EpoxyInterfaceType.DataType?, animated: Bool) {
    epoxyInterface?.apply(
      newInternalData,
      animated: animated) { [unowned self] newData in
        let oldInternalData = self.internalData
        self.internalData = newData
        guard let oldData = oldInternalData else {
          return nil
        }
        return newData?.makeChangeset(from: oldData)
    }
  }

  private func resetReuseIDs() {
    registerNewReuseIDs(oldReuseIDs: [], newReuseIDs: reuseIDs)
  }

  private func registerReuseIDs(with sections: [EpoxySection]?) {
    let newReuseIDs = getReuseIDs(from: sections)
    registerNewReuseIDs(oldReuseIDs: reuseIDs, newReuseIDs: newReuseIDs)
    reuseIDs = reuseIDs.union(newReuseIDs)
  }

  private func getReuseIDs(from sections: [EpoxySection]?) -> Set<String> {
    var newReuseIDs = Set<String>()

    sections?.forEach { section in
      let items: [EpoxyableModel] = section.items + [section.sectionHeader].flatMap { $0 }
      items.forEach { item in
        newReuseIDs.insert(item.reuseID)
      }
    }

    return newReuseIDs
  }

  private func registerNewReuseIDs(oldReuseIDs: Set<String>, newReuseIDs: Set<String>) {
    guard let epoxyInterface = epoxyInterface else {
      assertionFailure("Trying to unregister reuse IDs before the EpoxyInterface was set.")
      return
    }

    newReuseIDs.forEach { reuseID in
      if !oldReuseIDs.contains(reuseID) {
        epoxyInterface.register(reuseID: reuseID)
      }
    }
  }

}
