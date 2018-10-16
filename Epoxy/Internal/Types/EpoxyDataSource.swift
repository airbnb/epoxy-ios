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
      reregisterReuseIDs()
    }
  }

  private(set) var internalData: EpoxyInterfaceType.DataType?

  func setSections(_ sections: [EpoxyInterfaceType.DataType.ExternalSection]?, animated: Bool) {
    assert(Thread.isMainThread, "This method must be called on the main thread.")
    registerCellReuseIDs(with: sections)
    registerSupplementaryViewReuseIDs(with: sections)
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

  private var cellReuseIDs = Set<String>()
  private var supplementaryViewReuseIDs = [String: Set<String>]()

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

  private func reregisterReuseIDs() {
    registerNewCellReuseIDs(cellReuseIDs)
    supplementaryViewReuseIDs.forEach { elementKind, reuseIDs in
      registerNewSupplementaryViewReuseIDs(reuseIDs, forKind: elementKind)
    }
  }

  private func registerCellReuseIDs(with sections: [EpoxyInterfaceType.DataType.ExternalSection]?) {
    let newCellReuseIDs = sections?.getCellReuseIDs() ?? []
    registerNewCellReuseIDs(newCellReuseIDs.subtracting(cellReuseIDs))
    cellReuseIDs = cellReuseIDs.union(newCellReuseIDs)
  }

  private func registerSupplementaryViewReuseIDs(with sections: [EpoxyInterfaceType.DataType.ExternalSection]?) {
    let newSupplementaryViewReuseIDs = sections?.getSupplementaryViewReuseIDs() ?? [:]
    newSupplementaryViewReuseIDs.forEach { elementKind, newElementSupplementaryViewReuseIDs in
      let existingReuseIDs: Set<String> = supplementaryViewReuseIDs[elementKind] ?? []
      registerNewSupplementaryViewReuseIDs(newElementSupplementaryViewReuseIDs.subtracting(existingReuseIDs), forKind: elementKind)
      supplementaryViewReuseIDs[elementKind] = existingReuseIDs.union(newElementSupplementaryViewReuseIDs)
    }
  }

  private func registerNewCellReuseIDs(_ newCellReuseIDs: Set<String>) {
    guard let epoxyInterface = epoxyInterface else {
      assertionFailure("Trying to register reuse IDs before the EpoxyInterface was set.")
      return
    }
    newCellReuseIDs.forEach { cellReuseID in
      epoxyInterface.register(cellReuseID: cellReuseID)
    }
  }

  private func registerNewSupplementaryViewReuseIDs(_ newSupplementaryViewReuseIDs: Set<String>, forKind elementKind: String) {
    guard let epoxyInterface = epoxyInterface else {
      assertionFailure("Trying to register reuse IDs before the EpoxyInterface was set.")
      return
    }
    newSupplementaryViewReuseIDs.forEach { supplementaryViewReuseID in
      epoxyInterface.register(supplementaryViewReuseID: supplementaryViewReuseID, forKind: elementKind)
    }
  }
}
