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
    registerReuseIDs(with: sections)
    let oldInternalData = internalData
    if let sections = sections {
      internalData = EpoxyInterfaceType.DataType.make(with: sections)
    } else {
      internalData = nil
    }
    applyData(oldData: oldInternalData, animated: animated)
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

  private func applyData(oldData: EpoxyInterfaceType.DataType?, animated: Bool) {
    guard let oldData = oldData,
      let newData = internalData else {
        epoxyInterface?.reloadData()
        return
    }

    if animated {
      let changeset = newData.makeChangeset(from: oldData)
      epoxyInterface?.apply(changeset)
    } else {
      epoxyInterface?.reloadData()
    }
  }

  private func resetReuseIDs() {
    registerNewReuseIDs(oldReuseIDs: [], newReuseIDs: reuseIDs)
  }

  private func registerReuseIDs(with sections: [EpoxySection]?) {
    let newReuseIDs = getReuseIDs(from: sections)
    unregisterOldReuseIDs(oldReuseIDs: reuseIDs, newReuseIDs: newReuseIDs)
    registerNewReuseIDs(oldReuseIDs: reuseIDs, newReuseIDs: newReuseIDs)
    reuseIDs = newReuseIDs
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

  private func unregisterOldReuseIDs(oldReuseIDs: Set<String>, newReuseIDs: Set<String>) {
    guard let epoxyInterface = epoxyInterface else {
      assertionFailure("Trying to unregister reuse IDs before the EpoxyInterface was set.")
      return
    }

    oldReuseIDs.forEach { reuseID in
      if !newReuseIDs.contains(reuseID) {
        epoxyInterface.unregister(reuseID: reuseID)
      }
    }
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
